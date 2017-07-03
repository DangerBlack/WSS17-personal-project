{hold[TemplateApply[StringTemplate["Hello, my name is ``. I'm feeling ``."], 
   {"Bob", "good"}]], 
 hold[TemplateApply[StringTemplate[
    "Hello, my name is `2`. I'm feeling `1`."], {"good", "Bob"}]], 
 hold[TemplateApply[StringTemplate[
    "Hello, my name is `name`. I'm feeling `state`."], 
   Association["name" -> "Bob", "state" -> "good"]]]}
