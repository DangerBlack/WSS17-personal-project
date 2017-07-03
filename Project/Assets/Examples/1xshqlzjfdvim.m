{hold[entities = EntityValue[CountryData[], {"Name", "Population"}]; ], 
 hold[WordCloud[({Tooltip[#1[[1]], #1[[2]]], #1[[2]]} & ) /@ entities]]}
