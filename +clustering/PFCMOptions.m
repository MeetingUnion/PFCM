classdef PFCMOptions < fuzzy.clustering.FCMOptions
%PFCMOPTIONS 此处显示有关此函数的摘要
%   此处显示详细说明
    
    properties
        a = 1;      % 模糊系数
        b = 1;      % 可能性系数
        eta = 2;    % 可能性指数因子
        gamma = 6;
        % InitCenter = [];
    end

    methods
        function obj = PFCMOptions(varargin)
            obj@fuzzy.clustering.FCMOptions();  % 调用父类构造
            
            p = inputParser();
            % p.PartialMatching = true;       % 官方开启
            p.CaseSensitive = false;        % 官方关闭大小写敏感
            p.KeepUnmatched = true;

            addParameter(p, 'a', 1);
            addParameter(p, 'b', 1);
            addParameter(p, 'eta', 2);
            addParameter(p, 'gamma', 6);

            parse(p, varargin{:});

            obj.a = p.Results.a;
            obj.b = p.Results.b;
            obj.eta = p.Results.eta;
            obj.gamma = p.Results.gamma;

            % 2.把剩下未匹配的父类参数，批量赋值给父类属性
            unmatched = p.Unmatched;
            fd = fieldnames(unmatched);
            for i=1:length(fd)
                if isprop(obj, fd{i})
                    obj.(fd{i}) = unmatched.(fd{i});
                else
                    warning('Unknown parameter: %s',fd{i});
                end
            end
        end
    end


end

