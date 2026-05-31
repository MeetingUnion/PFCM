function varargout = myfcm(data, options)
    %   MYFCM 
    %   数据
    %   选项 options
        %   可选参数
    
    % return
    % center: 聚类中心
    % fuzzyPartMat: 模糊隶属度
    % objFcn: 目标函数
    dataSize = size(data, 1);
    objFcn = zeros(options.MaxNumIteration, 1);                  % 目标函数数组
    fuzzyMatrix = fuzzy.clustering.initfcm(options, dataSize);   % 初始模糊隶属度
    numClusters = options.NumClusters;
    expo = options.Exponent;
    % clusterVolume = options.ClusterVolume;                      % 马氏距离中体积/缩放系数 
    options.ClusterVolume = options.ClusterVolume(1,ones(1,options.NumClusters));
    brkCond = struct('isTrue',false,'description','');


    % Main Loop
    for iterId = 1 : options.MaxNumIteration
        memFcnMat = fuzzyMatrix.^expo;       
        center = memFcnMat * data ./ (sum(memFcnMat, 2) * ones(1, size(data, 2)));   
        % 是使用马氏距离还是欧氏距离
        if strcmp(options.DistanceMetric, getString(message('fuzzy:general:lblFcm_mahalanobis')))
            % dist 距离；covMat 协方差矩阵；brkCond 终止条件
            [dist, covMat, brkCond] = fuzzy.clustering.mahalanobisdist(center, data, memFcnMat, options.ClusterVolume);
        else
            dist = fuzzy.clustering.euclideandist(center, data);
            covMat = [];
        end

        tmp = (max(dist, eps)) .^ (-2 / (expo - 1));     % Calculate new Fuzzy Partition Matrix, suppose expo != 1
        fuzzyMatrix = tmp ./ (ones(numClusters, 1) * sum(tmp));
        objFcn(iterId) = sum(sum((dist .^ 2) .* memFcnMat));
    
        % 判断终止条件，返回true/false
        brkCond = checkBreakCondition(options, objFcn(iterId : -1 : max(1, iterId-1)), iterId, brkCond);
    
        % Check verbose condition
        % if options.Verbose
        %     fprintf(iterationProgressFormat, iterId, objFcn(iterId));
        %     if ~isempty(brkCond.description)
        %         fprintf('%s\n',brkCond.description);
        %     end
        % end
    
        % Break if early termination condition is true.
        if brkCond.isTrue
            objFcn(iterId+1:end) = [];
            break
        end
    end
    
    [varargout{1:nargout}] = assignOutputs(center,fuzzyMatrix,objFcn);

end

%% Local functions
function brkCond = checkBreakCondition(options, objFcn, iterId, stepBrkCond)
%%
    if stepBrkCond.isTrue
        brkCond = stepBrkCond;
        return
    end  
    brkCond = struct('isTrue',false,'description','');
    improvement = diff(objFcn);

    if ~isempty(improvement) && abs(improvement)<=options.MinImprovement
        % 达到阈值终止
        brkCond.isTrue = true;
        brkCond.description = getString(message('fuzzy:general:msgFcm_minImprovementReached'));
        return
    end
    
    if iterId==options.MaxNumIteration
        % 达到最大迭代次数终止
        brkCond.isTrue = true;
        brkCond.description = getString(message('fuzzy:general:msgFcm_maxIterationReached'));
    end
end

function varargout = assignOutputs(center,fuzzyPartMat,objFcn)
%% 返回参数
    if nargout>2
        varargout{3} = objFcn;
    end
    if nargout>1
        varargout{2} = fuzzyPartMat;
    end
    if nargout>0
        varargout{1} = center;
    end
end
