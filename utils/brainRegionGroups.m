

function groups = brainRegionGroups(style)

% co = get(gca, 'ColorOrder');
co = [         0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840;...
    [255 158 253]/255;... %pink
    0 0 0;...
    0.5*[1 1 1]];

% co = [55,126,184;...
%     228,26,28;...
%     77,175,74;...
%     152,78,163;...
%     0 0 0;...
%     0 0 0;...
%     166,86,40;...
%     255,127,0;...
%     0 0 0;...
%     0.5*255*[1 1 1]]/255;
g = 1;
groups(g).name = 'frontal';
groups(g).acr = {'MOs', 'ACA', 'PL', 'ILA', 'ORB'};
groups(g).color = co(2,:);

g = g+1;
groups(g).name = 'MOpSSp';
groups(g).acr = {'MOp', 'SSp'};
groups(g).color = co(4,:);

g = g+1;
groups(g).name = 'striatum';
groups(g).acr = {'CP', 'GPe', 'SNr', 'ACB', 'LS'};
groups(g).color = co(3,:);

g = g+1;
groups(g).name = 'midbrain';
groups(g).acr = {'MRN', 'SCm', 'SCs', 'APN', 'PAG'};
groups(g).color = co(7,:);

g = g+1;
groups(g).name = 'visual';
groups(g).acr = {'VISp', 'VISrl', 'VISam', 'VISpm', 'VISl', 'VISa'};
groups(g).color = co(1,:);

g = g+1;
groups(g).name = 'thalamus';
groups(g).acr = {'LP', 'LD', 'RT', 'MD', 'MG', 'LGd', 'VPM', 'VPL', 'PO', 'POL'};
groups(g).color = co(8,:); % pink

g = g+1;
groups(g).name = 'hippocampus';
groups(g).acr = {'POST', 'SUB', 'DG', 'CA1', 'CA3'};
groups(g).color = co(9,:);

g = g+1;
groups(g).name = 'other';
groups(g).acr = {'ZI', 'OLF', 'BLA', 'RSP'};
groups(g).color = co(10,:);

if nargin>0
    switch style
        case 'gradient'
            clear groups
            g = 0; coIdxStart = 3; 

            n = 7; %co = copper(n+2); 
            co = myCopper(0.1, n+coIdxStart-1);%
            coIdx = coIdxStart;
            g = g+1; groups(g).acr = {'ACA'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MOs'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'PL'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ILA'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ORB'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MOp'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'SSp'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;

            n = 5; %co = copper(n+2);  co = co(:,[2 3 1]);
            co = myCopper(0.72, n+coIdxStart-1);
            coIdx = coIdxStart;
            g = g+1; groups(g).acr = {'CP'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'GPe'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'SNr'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ACB'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'LS'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;

            n = 5; %co = copper(n+2);  co = co(:,[2 1 3]); 
            co = myCopper(0, n+coIdxStart-1);
            coIdx = coIdxStart;
            g = g+1; groups(g).acr = {'SCs'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'SCm'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MRN'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'APN'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'PAG'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;

            n = 6; %co = copper(n+2);co = co(:,[3 2 1]); 
            co = myCopper(0.6, n+coIdxStart-1);  %
            coIdx = coIdxStart;
            g = g+1; groups(g).acr = {'VISp'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISl'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISpm'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISam'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISrl'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISa'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;

            n = 10; %co = copper(n+2);  co = co(:,[3 1 2]); coIdx = coIdxStart;
            co = myCopper(0.3, n+coIdxStart-1);  %
            coIdx = coIdxStart;
            g = g+1; groups(g).acr = {'LGd'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'LP'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'LD'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'POL'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MD'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VPL'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'PO'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VPM'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'RT'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MG'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;

            n = 5; %co = copper(n+2);  co = co(:,[1 3 2]); coIdx = coIdxStart;
            co = myCopper(0.89, n+coIdxStart-1);  %
            coIdx = coIdxStart;
            g = g+1; groups(g).acr = {'DG'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'CA3'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'CA1'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;    
            g = g+1; groups(g).acr = {'SUB'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'POST'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;        

            co = repmat(linspace(0, 1, 5)', 1, 3); coIdx = 1;
            g = g+1; groups(g).acr = {'RSP'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ZI'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'OLF'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'BLA'}; groups(g).color = co(coIdx,:); coIdx = coIdx+1;

        case 'LRgroups'
            clear groups; g = 1;
            groups(g).name = 'frontal';
            groups(g).acr = {'MOs', 'PL'};
            groups(g).color = hsv2rgb(0.1, 0.6, 0.375);

            g = g+1;
            groups(g).name = 'MOp';
            groups(g).acr = {'MOp'};
            groups(g).color = hsv2rgb(0.1, 0.6, 0.875);

            g = g+1;
            groups(g).name = 'striatum';
            groups(g).acr = {'CP'};
            groups(g).color = hsv2rgb(0.72, 0.6, 0.6);

            g = g+1;
            groups(g).name = 'midbrain';
            groups(g).acr = {'MRN', 'SCm', 'SNr'};
            groups(g).color = hsv2rgb(0, 0.6, 0.6);
            
        case 'LRgroups2'
            clear groups; g = 1;
            groups(g).name = 'frontal';
            groups(g).acr = {'MOs', 'PL', 'MOp'};
%             groups(g).acr = {'MOs', 'PL'};
            groups(g).color = hsv2rgb(0.1, 0.6, 0.8);            

%             g = g+1;
%             groups(g).name = 'MOp';
%             groups(g).acr = {'MOp'};
%             groups(g).color = hsv2rgb(0.1, 0.6, 0.875);
            
            g = g+1;
            groups(g).name = 'striatum';
            groups(g).acr = {'CP'};
            groups(g).color = hsv2rgb(0.72, 0.6, 0.6);

            g = g+1;
            groups(g).name = 'midbrain';
            groups(g).acr = {'MRN', 'SCm', 'SNr', 'ZI'};
            groups(g).color = hsv2rgb(0, 0.6, 0.6);    
        case 'LRgroupsMOp'
            clear groups; g = 1;
            groups(g).name = 'frontal';
%             groups(g).acr = {'MOs', 'PL', 'MOp'};
            groups(g).acr = {'MOs', 'PL'};
            groups(g).color = hsv2rgb(0.1, 0.6, 0.375);            

            g = g+1;
            groups(g).name = 'MOp';
            groups(g).acr = {'MOp'};
            groups(g).color = hsv2rgb(0.1, 0.6, 0.875);
            
            g = g+1;
            groups(g).name = 'striatum';
            groups(g).acr = {'CP'};
            groups(g).color = hsv2rgb(0.72, 0.6, 0.6);

            g = g+1;
            groups(g).name = 'midbrain';
            groups(g).acr = {'MRN', 'SCm', 'SNr', 'ZI'};
            groups(g).color = hsv2rgb(0, 0.6, 0.6);
            
        case 'byStructure'
            clear groups
            g = 0; coIdxStart = 3; 

            n = 7; %co = copper(n+2); 
            co = myCopper(0.1, n+coIdxStart-1);%
            coIdx = 8;
            g = g+1; groups(g).acr = {'ACA'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MOs'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'PL'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ILA'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ORB'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MOp'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'SSp'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;

            n = 5; %co = copper(n+2);  co = co(:,[2 3 1]);
            co = myCopper(0.72, n+coIdxStart-1);
            coIdx = 6;
            g = g+1; groups(g).acr = {'CP'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'GPe'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'SNr'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ACB'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'LS'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;

            n = 5; %co = copper(n+2);  co = co(:,[2 1 3]); 
            co = myCopper(0, n+coIdxStart-1);
            coIdx = 6;
            g = g+1; groups(g).acr = {'SCs'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'SCm'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MRN'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'APN'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'PAG'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'ZI'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            
            n = 6; %co = copper(n+2);co = co(:,[3 2 1]); 
            co = myCopper(0.6, n+coIdxStart-1);  %
            coIdx = 7;
            g = g+1; groups(g).acr = {'VISp'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISl'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISpm'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISam'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISrl'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VISa'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;

            n = 10; %co = copper(n+2);  co = co(:,[3 1 2]); coIdx = coIdxStart;
            co = myCopper(0.3, n+coIdxStart-1);  %
            coIdx = 8;
            g = g+1; groups(g).acr = {'LGd'}; groups(g).color = co(coIdx,:); 
            g = g+1; groups(g).acr = {'LP'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'LD'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'POL'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MD'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VPL'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'PO'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'VPM'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'RT'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'MG'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;

            n = 5; %co = copper(n+2);  co = co(:,[1 3 2]); coIdx = coIdxStart;
            co = myCopper(0.89, n+coIdxStart-1);  %
            coIdx = 6;
            g = g+1; groups(g).acr = {'DG'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'CA3'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'CA1'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;    
            g = g+1; groups(g).acr = {'SUB'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'POST'}; groups(g).color = co(coIdx,:);% coIdx = coIdx+1;        

            co = repmat(linspace(0, 1, 5)', 1, 3); coIdx = 3;
            g = g+1; groups(g).acr = {'RSP'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;            
            g = g+1; groups(g).acr = {'OLF'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
            g = g+1; groups(g).acr = {'BLA'}; groups(g).color = co(coIdx,:); %coIdx = coIdx+1;
        otherwise
            fprintf(1, 'unrecognized style %s\n', style); 
    end
end
end