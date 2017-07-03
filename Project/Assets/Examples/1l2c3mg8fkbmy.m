{hold[pts = {{0, 1}, {-1, -(1/2)}, {1, -(1/2)}}; ], 
 hold[Graphics[FilledCurve[{{Line[2*pts]}, {Line[pts]}}]]], 
 hold[Graphics[FilledCurve[{{Line[pts]}, 
     {Line[TranslationTransform[{1, 1/2}][pts]]}}]]]}
