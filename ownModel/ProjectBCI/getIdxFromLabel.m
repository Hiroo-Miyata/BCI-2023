function labelIdx = getIdxFromLabel(labels, labelnames, outlierIdx)
    labelIdx = [];
    for label = labelnames
        laplacianNumber = find(strcmp(labels,label));
        if ~ismember(laplacianNumber,outlierIdx)
            labelIdx(end+1) = laplacianNumber;                  %Find the corresponding electrode number in 'labels'
        end
    end
end