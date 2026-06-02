classdef PFCMOptions < fuzzy.clustering.FCMOptions
%PFCMOPTIONS 此处显示有关此函数的摘要
%   此处显示详细说明
    
    properties
        a {validateA} = clustering.PFCMOptions.DefaultA;      % 模糊系数
        b {validateB} = clustering.PFCMOptions.DefaultB;      % 可能性系数
        eta {validateEta} = clustering.PFCMOptions.DefaultEta;    % 可能性指数因子
        gamma {validateGamma} = clustering.PFCMOptions.DefaultGamma;    % 惩罚因子
        % InitCenter = [];
    end

    properties(Constant, Hidden)
        DefaultA = 1;
        DefaultB = 1;
        DefaultEta = 2;
        DefaultGamma = 6;
    end

    methods
        function obj = PFCMOptions(varargin)
            obj@fuzzy.clustering.FCMOptions();  % 调用父类构造
            
            p = inputParser();
            % p.PartialMatching = true;       % 官方开启
            p.CaseSensitive = false;        % 官方关闭大小写敏感
            p.KeepUnmatched = true;

            addParameter(p, 'a', clustering.PFCMOptions.DefaultA);
            addParameter(p, 'b', clustering.PFCMOptions.DefaultB);
            addParameter(p, 'eta', clustering.PFCMOptions.DefaultEta);
            addParameter(p, 'gamma', clustering.PFCMOptions.DefaultGamma);

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

%% local function
function validateA(value)
    validateattributes(value,...
        {'numeric'},...
        {'nonempty','scalar','real','finite','positive'},...
        '',...
        'a');
end


function validateB(value)
    validateattributes(value,...
        {'numeric'},...
        {'nonempty','scalar','real','finite','positive'},...
        '',...
        'b');
end

function validateEta(value)
    validateattributes(value,...
        {'numeric'},...
        {'nonempty','scalar','real','finite','>',1},...
        '',...
        'eta');
end

function validateGamma(value)
    validateattributes(value,...
    {'numeric'},...
    {'nonempty','scalar','real','finite','positive'},...
    '',...
    'gamma');
end
