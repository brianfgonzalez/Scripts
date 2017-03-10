Function UserExit(sType, sWhen, sDetail, bSkip)

      UserExit = Success

End Function

Function Left4(Input)
   
    Left4=Left(Input,4)

End Function

Function Right10(Input)
   
    Right10=Right(Input,10)

End Function

Function SpecialDate()
    SpecialDate = DatePart("yyyy",Date) & _
      Right("0" & DatePart("m",Date), 2) & _
      Right("0" & DatePart("d",Date), 2)
End Function