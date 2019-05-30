

function plotRecLocsMapByColor(sagAx, topdownAx, uacr, colors, st, av, tpidx)


% st = loadStructureTree();
if ~exist('tpidx', 'var')
    [tpidx, tp] = makeSTtree(st);
end

% steps: 
% 4. choose a few slices

% coronal
% avs = squeeze(av(850,:,:));
% avs = avs(:,1:size(avs,2)/2);

% horiz
% avs = squeeze(av(:,300,:));
% avs = avs(:,1:size(avs,2)/2);

if ~isempty(sagAx)
    % sagittal
    sliceName = 'sagittal'; slicePos = 400; 
    avs = squeeze(av(:,:,slicePos))';
    
    plotRLMBChelp(sagAx, avs, uacr, colors, st, tpidx);
end

if ~isempty(topdownAx)
    % sagittal
    [~,ii] = max(av>1, [], 2);
    ii = squeeze(ii);
    [xx,yy] = meshgrid(1:size(ii,2), 1:size(ii,1));
    avs = reshape(av(sub2ind(size(av),yy(:),ii(:),xx(:))), size(av,1), size(av,3));
    % avs = avs(:,1:size(avs,2)/2);
    sliceName = 'topdown'; slicePos = 0;
    
    plotRLMBChelp(topdownAx, avs, uacr, colors, st, tpidx);
end
    
function plotRLMBChelp(ax, avs, uacr, colors, st, tpidx)

[~,~,h] = sliceOutlineWithRegionVec(avs, [], [],ax);

set(h, 'Color', 0.5*[1 1 1]); 
hold on; 

for q = 1:numel(uacr)
    uIdx = find(strcmp(st.acronym, uacr{q}));

    below = [uIdx; tpidx(tpidx(:,1)==uIdx,2)];
    
    [ii,jj] = find(ismember(avs,below)); 
    if ~isempty(ii)
                
        thisColor = colors(q,:);
        
        c = contourc(double(ismember(avs,below)), [0.5 0.5]);
        coordsReg = makeSmoothCoords(c);                
        for cidx = 1:numel(coordsReg)
            h = fill(ax, coordsReg(cidx).x,coordsReg(cidx).y, thisColor); hold on;
            h.FaceAlpha = 0.75;
        end                
        
    end
end

% add annotations last so they're on top
% for q = 1:numel(uIdx)
%     
%     below = [uIdx(q); tpidx(tpidx(:,1)==uIdx(q),2)];
%     
%     [ii,jj] = find(ismember(avs,below));
%     if ~isempty(ii)
%         
%         gIdx = find(strcmp(arrayfun(@(x)g(x).acr{1}, 1:numel(g), 'uni', false), uacr{q}));
%         thisColor = g(gIdx).color;
%         
%         comX = mean(ii); comY = mean(jj);
%         thisAcr = st.acronym{uIdx(q)};
%         theseR = strcmp(recTable.acr, thisAcr);
%         ah = annotation('textbox','String', ...
%             {sprintf('%s', thisAcr), ...
%             sprintf('(%d; %d/%d)', sum(theseR), ...
%             sum(recTable.incl(theseR)), sum(recTable.all(theseR)))});
%         ah.HorizontalAlignment = 'center';
%         set(ah, 'Parent', gca, 'Position', [comY-25 comX-10 1 1],...
%             'LineStyle', 'none', 'Color', thisColor, 'FontWeight', 'bold');
%     end
% end
