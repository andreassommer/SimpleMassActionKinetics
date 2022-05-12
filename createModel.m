function model = createModel(name, reactions, species, parameters)
   % modell = createModel(name, reactions, species, [parameters])
   %
   % Create model structure from given reactions and species
   %
   % INPUT:    name        - string
   %           reactions   - reaction structure
   %           species     - cell array of strings
   %           parameters  - cell array of strings
   %
   % OUTPUT:   model       - model structure
   %
   %
   % [andreas.sommer@iwr.uni-heidelberg.de - 25.05.2009]
   %
   if ~exist('parameters','var'),  parameters = ''; end
   model.name       = name;
   model.reactions  = reactions;
   model.species    = species;
   model.parameters = parameters;
end