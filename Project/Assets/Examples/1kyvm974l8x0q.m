{hold[StringTemplate["Values: <* Range[5] *>."][]], 
 hold[StringTemplate["Value `a`: <* Range[5] *>."][
   Association["a" -> 1234]]], 
 hold[StringTemplate["Value `a`: <* Range[#n] *>."][
   Association["a" -> 1234, "n" -> 3]]], 
 hold[data = Association["a" :> RandomReal[]]; , Null, 
  TemplateApply["a is `a`", data]], 
 hold[TemplateApply["my favorite number is `a`", data]]}
