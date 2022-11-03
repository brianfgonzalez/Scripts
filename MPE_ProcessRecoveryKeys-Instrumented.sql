--
-- Name         : MPE_ProcessRecoveryKeys
-- Definition   : SqlObjs
-- Scope        : CAS_OR_PRIMARY_OR_SECONDARY
-- Object       : P
-- Dependencies : <Detect>
-- Description  : Process Recovery Keys
--
ALTER PROCEDURE [dbo].[MPE_ProcessRecoveryKeys]
@Messages BigIntXmlList READONLY,
@FailMessagesXML XML OUTPUT
AS
BEGIN

    SET @FailMessagesXML = NULL

    DECLARE @FailMessages TABLE (ID BIGINT NOT NULL PRIMARY KEY, Exception NVARCHAR(MAX) NOT NULL, CanRetry BIT NOT NULL)

    -- Parse message one by one and put into temp table variable
    -- For any parse failed message, put into failed message list to return
    DECLARE @MessageId BIGINT
    DECLARE @MessageXml XML
    DECLARE @RetVal INT
    DECLARE @MessageText NVARCHAR(MAX)
    DECLARE @ErrorText NVARCHAR(MAX)

    DECLARE messageCursor CURSOR LOCAL FAST_FORWARD FOR SELECT BigIntValue AS MessageId, XmlValue AS MessageXml FROM @Messages 
     
    OPEN messageCursor;    
    FETCH NEXT FROM messageCursor INTO @MessageId, @MessageXml;   
    WHILE @@FETCH_STATUS = 0   
    BEGIN 

        BEGIN TRY

			DECLARE @LogString varchar(256)    -- For vLog entry
 
            DECLARE @Encoded AS NVARCHAR(MAX) 
            DECLARE @Decoded AS VARBINARY(MAX) 
            DECLARE @DecryptedMessageXml AS XML 
             
            SELECT @Encoded = T.X.value('./Encrypted[1]', 'NVARCHAR(MAX)') FROM @MessageXml.nodes('/') AS T(X) 
            SET @Decoded = cast('' as xml).value('xs:base64Binary(sql:variable("@Encoded"))', 'varbinary(max)') 
 
            SET @DecryptedMessageXml = RecoveryAndHardwareCore.DecryptString(@Decoded, DEFAULT) 
 
            DECLARE @ClientID NVARCHAR(255) 
            DECLARE @ResourceID INT 
            DECLARE @ComputerNameFromXML NVARCHAR(MAX) 
            DECLARE @ComputerNameFromSystemDISC NVARCHAR(256) 
            DECLARE @Provisioning NVARCHAR(255)
             
            -- <RecoveryInfo ClientId="SMSID">...</RecoveryInfo> 
            SELECT 
                @ClientID = T.X.value('./@ClientId', 'NVARCHAR(255)') 
            FROM @DecryptedMessageXml.nodes('/RecoveryInfo ') AS T(X) 

            SELECT 
                @Provisioning = T.X.value('./@Provisioning', 'NVARCHAR(255)')
            FROM @DecryptedMessageXml.nodes('/RecoveryInfo ') AS T(X) 

            SELECT @ComputerNameFromXML = T.X.value('./Name[1]', 'NVARCHAR(MAX)') 
                FROM @DecryptedMessageXml.nodes('/RecoveryInfo/Computer') AS T(X) 
			
			IF @Provisioning IS NOT NULL AND @Provisioning = 'true' 
			BEGIN
				SET @ResourceID = 0
			END
			ELSE
            BEGIN
                SELECT @ResourceID = ItemKey, @ComputerNameFromSystemDISC = Netbios_Name0 FROM System_DISC 
                    WHERE SMS_Unique_Identifier0 = @ClientID AND ISNULL(Decommissioned0, 0) = 0 AND ISNULL(Obsolete0, 0) = 0 
            END

			SELECT @LogString = 'ComputerNameFromSystemDISC: ' + @ComputerNameFromSystemDISC + ', ResourceID: ' + CONVERT(varchar(12),@ResourceID,1)    -- For vLog entry
			EXEC spLogEntry @LogString,NULL,N'MPE_ProcessRecoveryKeys'    -- For vLog entry

            IF @ResourceID IS NULL
			BEGIN
				EXEC spLogEntry N'ResourceID IS NULL',NULL,N'MPE_ProcessRecoveryKeys'    -- For vLog entry
                INSERT INTO @FailMessages VALUES (@MessageId, N'Client not found', 0)
			END
            ELSE
            BEGIN 
                IF @ResourceID <> 0 AND @ComputerNameFromSystemDISC <> @ComputerNameFromXML 
                    INSERT INTO @FailMessages VALUES (@MessageId, N'Computer name from payload does not match System_DISC Netbios_Name0 value', 0) 
                ELSE 
                BEGIN 
                    SET @MessageText =  CONVERT(NVARCHAR(MAX), @DecryptedMessageXml)
					
					SELECT @LogString = 'MessageText: ' + @MessageText    -- For vLog entry
					EXEC spLogEntry @LogString,NULL,N'MPE_ProcessRecoveryKeys'    -- For vLog entry

                    EXEC @RetVal = [dbo].[ProcessRecoveryPayloadXml] @payloadXml = @MessageText, @resourceId = @ResourceID, @error = @ErrorText output 
 
                    IF @RetVal <> 0 
	                    INSERT INTO @FailMessages VALUES (@MessageId, @ErrorText, 0) 
                END 
            END 
             
        END TRY 
        BEGIN CATCH
            INSERT INTO @FailMessages VALUES (@MessageId, ERROR_MESSAGE(), 0)
        END CATCH

        FETCH NEXT FROM messageCursor INTO @MessageId, @DecryptedMessageXml;   
    END 
    CLOSE messageCursor; 
    DEALLOCATE messageCursor; 

    -- Set fail messages xml
    SET @FailMessagesXML = (SELECT ID, Exception, CanRetry FROM @FailMessages FOR XML PATH('Message'), ROOT('FailMessages'))

END