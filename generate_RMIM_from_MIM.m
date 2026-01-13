function RMIM = generate_RMIM_from_MIM(MIM, o,DO, C_MIM, mode)
% generate_RMIM_from_MIM - 生成旋转不变最大索引图，支持左右旋模式
% 输入:
%   MIM - 最大索引图
%   C_MIM - 主导方向索引
%   o - 方向数量
%   DO - 主导方向角度
%   mode - 旋转模式: 0=左旋(默认), 1=右旋

    % 验证模式参数
    if mode ~= 0 && mode ~= 1
%         RMIM = MIM;%不使用RMIM
    MIM_new = MIM - C_MIM + 1;
    % 处理边界情况（索引小于1）
    MIM_new(MIM_new < 1) = MIM_new(MIM_new < 1) + o;
    RMIM = MIM_new;%进行RMIM变换 不对RMIM进行旋转
        return;
    end
    % 根据模式调整旋转角度
    if mode == 1
        % 右旋模式：增加180度
        adjusted_DO = DO + 180;
        fprintf('右旋模式: DO从%.1f°调整为%.1f°\n', DO, adjusted_DO);
    else
        % 左旋模式：保持不变
        adjusted_DO = DO;
        fprintf('左旋模式: 保持DO=%.1f°\n', DO);
    end
    % 重新计算MIM（循环移位）
    MIM_new = MIM - C_MIM + 1;
    % 处理边界情况（索引小于1）
    MIM_new(MIM_new < 1) = MIM_new(MIM_new < 1) + o;
    % 调用旋转函数，传入调整后的角度 
    angle_map = (MIM_new - 1) * (180 / o);
    rotated_angle = imrotate(angle_map, DO, 'nearest', 'crop');
    rotated_angle = mod(rotated_angle, 180);
    
    % 转换回索引
    RMIM = ceil(rotated_angle / (180 / o));
    RMIM(RMIM == 0) = o;
    
%     RMIM=imrotate(MIM_new,adjusted_DO);
%       RMIM = MIM_new;
%     RMIM = rotate_preserve_index(MIM_new, adjusted_DO, o, true); % 使用crop模式
end

