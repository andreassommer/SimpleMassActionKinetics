function newModel = addDelay(model, delayreaction, delaydepth, delayrate, delayname)
   % function newModel = addDelay(model, delayreaction, delaydepth, delayrate, [delayname])
   % 
   % Add a delay to a specified reaction in given reaction collection. 
   % The delay is inserted; the original reaction rate is used in last step of delayed reactions.
   %
   % INPUT:    model          - model structure
   %           delayreaction  - integer (number of reaction to delay)
   %           delaydepth     - integer (number of delaying reactions being inserted)
   %           delayrate      - string  (reaction rate for delay reactions)
   %           delayname      - string  (optional name for the delay reactions)
   %
   % The delayed reactions have the original or the specified name, both with '_Delay' suffix. 
   % The delay wear a 'DelaySpecies' suffix instead.
   %
   % [andreas.sommer@iwr.uni-heidelberg.de - 25.05.2009]
   %
   
   % if delaydepth is zero, return original model
   if (delaydepth == 0) , newModel = model; return; end
   
   % ensure that delayrate is a string
   if isnumeric(delayrate),  delayrate = strtrim(sprintf('%30.18g',delayrate));
   
   % set variables
   reactions  = model.reactions;
   species    = model.species;
   parameters = model.parameters;
   whitespace = [' ', sprintf('\t')];

   % set name of delay
   if exist('delayname','var')
      name      = delayname;
   else
      name      = removeCharsFromString(reactions(delayreaction).name, whitespace);
   end
   
   % get reaction to delay
   educts       = reactions(delayreaction).educts;
   products     = reactions(delayreaction).products;
   originalrate = reactions(delayreaction).rate;
   originalmod  = reactions(delayreaction).modifier;
   
   % function for creating names of the form:  name_delayXX
   createDelayReactionName = inline('[name ''_Delay''        sprintf(''%02d'',number) ]', 'name', 'number');  
   createDelaySpeciesName  = inline('[name ''_DelaySpecies'' sprintf(''%02d'',number) ]', 'name', 'number');
   
   % create delayed reactions
   delayreactions(1) = createReaction(createDelayReactionName(name,1), educts.names, educts.factors, createDelaySpeciesName(name,1), 1, delayrate);
   for j = 2:(delaydepth)
      delayreactions(j) = createReaction(createDelayReactionName(name,j), createDelaySpeciesName(name,j-1), 1, createDelaySpeciesName(name,j), 1, delayrate);
   end
   delayreactions(delaydepth+1) = createReaction(name, createDelaySpeciesName(name,delaydepth), 1, products.names, products.factors, originalrate, originalmod);
   
   % insert new species
   newspecies = species;
   for j = 1:delaydepth
      newspecies{end+1} = createDelaySpeciesName(name,j);
   end
   
   % replace old reaction by delayed cascade
   numreactions = length(reactions) + delaydepth;
   newreactions(            1:delayreaction            ) = reactions(1:delayreaction);
   newreactions(delayreaction:delayreaction+delaydepth ) = delayreactions(1:end);
   newreactions(delayreaction+delaydepth+1:numreactions) = reactions(delayreaction+1:end);   
   
   % set up new model
   newModel = createModel(model.name, newreactions, newspecies, parameters);
end   