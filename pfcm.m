function varargout = pfcm(data, options)
% Possibilistic Fuzzy C-Means 
%    [P,U,g,Sellipse,J,t] = pfcm(x,K,varargin)
%
% INPUTS
%   x: input matrix nxd
%   c: number of desired clusters
%   varargin: optional arguments
%   - 'distance': 'sqEuclidean' (default) or 'Mahalanobis'
%   - 'rho' : 1xc vector for the volume of the ellipse (1 vector by default)
%   - 'ginit': matrix Kxd corresponding to the initial centers of the clusters
%              (random initialization by default)
%   - 'm' : coefficient controling the fuzziness of the probabilistic partition
%           (2 by default)
%   - 'a': coefficient >0 giving importance to probability memberships (1
%          by default)
%   - 'b': coefficient >0 giving importance to typicality memberships (1
%          by default) 
%   - 'eta': coefficients controling the fuzziness of the typicality values
%            (2 by default)
%   - 'gamma' : vector (1xc) of coefficients controling the Krishnapuram and 
%               Keller term.
%   - 'debug': check that the objectif function is well-minimized (0 by default)
%
% OUTPUTS
%   T: possibilistic partition (equal to typicality values)
%   U: fuzzy partition
%   g: matrix Kxd corresponding to the centers of the clusters
%   Sellipse: covariance matrices Kx(pxp) if existing (Mahalanobis case)
%   J: result of the objective function
%   t: iterations made before convergence
%   errMin: error in the minimization (debug option)
%
% Reference:
% [1]  N. Pal, K. Pal, J. Keller, and J. Bezdek. A possibilistic fuzzy
% c-means clustering algorithm. IEEE Transactions on Fuzzy Systems, 2005.
% [2] B. Ojeda-Magana, R. Ruelas, M. Corona-Nakamura, and D. Andina. An
%     improvement to the possibilistic fuzzy c-means clustering algorithm. 
%     World Automatic Control Conference  (WAC06), 2006.
%
%  --------------------------------------------------------------------------
% Author : Violaine Antoine
% mail   : violaine.antoine@uca.fr
% date   : 07-26-2017
% version: 1.0

%%%%%%%%%%%%% Initializations %%%%%%%%%%%%% 

dataSize = size(data, 1);
objFcn = zeros(options.MaxNumIteration, 1);                  % 目标函数数组
fuzzyMatrix = fuzzy.clustering.initfcm(options, dataSize);   % 初始模糊隶属度
possibilicticMatrix = fuzzy.clustering.initfcm(options, dataSize);   % 初始模糊隶属度
numClusters = options.NumClusters;
expo = options.Exponent;                                    % 模糊指数因子
eta = options.eta;                                          % 可能性指数因子
gamma = options.gamma;                                      % 惩罚因子
% clusterVolume = options.ClusterVolume;                      % 马氏距离中体积/缩放系数 
a = options.a; b = options.b;
options.ClusterVolume = options.ClusterVolume(1,ones(1,options.NumClusters));
brkCond = struct('isTrue',false,'description','');


%% ------------------------ iterations--------------------------------

% Main Loop
for iterId = 1 : options.MaxNumIteration
    memFcnMat = a * fuzzyMatrix .^ expo + b * possibilicticMatrix .^ eta;       
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

    temp = (b * dist .^ 2 ./ gamma) .^ (1 / (expo - 1));
    possibilicticMatrix = (1 ./ (1 + temp));

    objFcn(iterId) = sum(sum((dist .^ 2) .* memFcnMat)) + sum(gamma .* sum((1 - possibilicticMatrix) .^ eta, 2));

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

end
