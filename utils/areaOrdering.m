

function manOrder = areaOrdering(type)

manOrder = {};
switch type
    case 'manualByLatency'
        manOrder = {'SCs', 'VISp', 'LP', 'VISl', 'VISpm', 'VISam','VISrl', ...
            'VISa', 'LD','CP',      ...
             'ACA',  'MOs','PL','GPe', 'SCm','MRN','SNr', ...
            'ZI', 'APN','ORB', 'ILA', 'ACB', ...
            'MOp', 'RSP', 'SSp', ...
            'VPL', 'LGd', 'MD', 'PO', 'POL', 'MG', 'RT','VPM',  ...
            'DG', 'CA3', 'CA1', 'POST', 'SUB', ...
            'LS', 'PAG', 'OLF', 'BLA'}';
        
    case 'manualByStream'
        manOrder = {'SCs', 'SCm', 'APN', 'MRN', 'PAG', ... % midbrain
            'VISp', 'LP', 'VISl','VISpm',  'VISam', 'VISrl', 'VISa',... % visual cortical pathway
            'PL', 'ACA', 'MOs', 'ORB','MOp', 'ILA',  'RSP', 'SSp',... % other cortex
            'CP', 'GPe', 'SNr','ACB',... % basal ganglia
            'LD', 'POL', 'MD', 'VPL','PO', 'VPM', 'RT','MG', ...
            'DG', 'CA3', 'CA1', 'POST', 'SUB', ... % hippocampus
            'ZI', 'OLF', 'LS', 'BLA', 'LGd'}'; % non-responsive/other
        
    case 'anatomy'
        manOrder = {
            'VISp', 'VISl', 'VISpm',  'VISam', 'VISrl', 'VISa',... % vis ctx
            'RSP', 'ACA', 'MOs', 'PL', 'ILA', 'ORB', 'MOp','SSp',... % other isocortex            
            'DG', 'CA3', 'CA1', 'POST', 'SUB', ... % hippocampus
            'OLF', 'BLA', ... % other cortex
            'CP', 'GPe', 'SNr', 'ACB', 'LS', ... % basal ganglia
            'LGd', 'LP', 'LD', 'POL', 'MD', 'VPL', 'PO', 'VPM', 'RT', 'MG', ... thalamus
            'SCs', ... % midbrain sensory
            'SCm', 'MRN', 'APN', 'PAG', ... % midbrain motor
            'ZI'}'; % other
            
end