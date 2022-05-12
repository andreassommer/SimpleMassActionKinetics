function val = reactionmanagement()
   
   % Species
   species = {'GMCSF','RC_GMCSF','LRC_GMCSF'};
   
   % create reactions   
   reactions(1) = createReaction('GMCSF-Rezeptoraktivierung', {'GMCSF','RC_GMCSF'}, {}, {'LRC_GMCSF'}       , {}, 0.3, '');
   reactions(2) = createReaction('GMCSF-Rezeptorzerfall'    , {'LRC_GMCSF'}       , {}, {'GMCSF','RC_GMCSF'}, {}, 0.1, '');   
   reactions(3) = createReaction('GMCSF-Zerfall'            , {'GMCSF'}           , {}, {}                  , {}, 0.3, 'mf*p(7)');

   model = createModel('TestModell', reactions, species);
   
%   newmodel = addDelay(model, 1, 3, 2);

   writeCodeFromModel('MATLAB_SM',model,'dada.m',1);
   writeCodeFromModel('MATLAB_ODE',model,'dada2.m',1);
   writeCodeFromModel('VPLAN_TEST',model,'dada3.m',1);
 
   %lesbar = getReadibleReactions(model);
   
   val = model;
   
   %
   %  Was ist bei "Kein Edukt" (-> Produktion von Stoffen)   ???
   %  und bei "Kein Produkt"   (-> Zerfall von Stoffen)      ???
   %
end
