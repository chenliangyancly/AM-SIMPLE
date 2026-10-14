function AM_Simulation
% AM 调制解调综合仿真（MATLAB Online 兼容，保持原布局）

    A0 = 1.5;

    % Figure 用归一化，适应网页
    fig = figure('Units', 'normalized', ...
                 'Position', [0.05 0.05 0.9 0.85], ...
                 'Color', 'w', ...
                 'MenuBar', 'figure', ...
                 'Name', 'AM Modulation Simulation');
    
    % 面板保持绝对像素（因为里面控件也是绝对像素）
    panel = uipanel('Parent', fig, 'Title', 'Parameters', ...
                    'Units', 'pixels', ...
                    'Position', [10 10 200 700], ...
                    'FontSize', 10);
    
    % ===== fm 滑块 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Modulating Freq fm (Hz)', ...
              'Units', 'pixels', ...
              'Position', [10 620 180 20], ...
              'HorizontalAlignment', 'left');
    s_fm = uicontrol('Parent', panel, 'Style', 'slider', ...
                     'Min', 1, 'Max', 20, 'Value', 5, ...
                     'Units', 'pixels', ...
                     'Position', [10 600 180 20], ...
                     'Tag', 's_fm');
    
    % ===== fc 滑块 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Carrier Freq fc (Hz)', ...
              'Units', 'pixels', ...
              'Position', [10 560 180 20], ...
              'HorizontalAlignment', 'left');
    s_fc = uicontrol('Parent', panel, 'Style', 'slider', ...
                     'Min', 50, 'Max', 200, 'Value', 100, ...
                     'Units', 'pixels', ...
                     'Position', [10 540 180 20], ...
                     'Tag', 's_fc');
    
    % ===== Am 滑块 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Modulating Amp Am (0.1~2.0)', ...
              'Units', 'pixels', ...
              'Position', [10 500 180 20], ...
              'HorizontalAlignment', 'left');
    s_Am = uicontrol('Parent', panel, 'Style', 'slider', ...
                     'Min', 0.1, 'Max', 2.0, 'Value', 1.0, ...
                     'Units', 'pixels', ...
                     'Position', [10 480 180 20], ...
                     'Tag', 's_Am');
    
    % ===== A0 固定显示 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', sprintf('DC Offset A0 = %.1f (fixed)', A0), ...
              'Units', 'pixels', ...
              'Position', [10 440 180 20], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold', 'ForegroundColor', [0 0.4 0.8]);
    
    % ===== 按钮 =====
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Overmodulation Demo', ...
              'Units', 'pixels', ...
              'Position', [10 390 180 30], ...
              'Callback', @overmod_demo);
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Normal AM', ...
              'Units', 'pixels', ...
              'Position', [10 350 180 30], ...
              'Callback', @normal_demo);
    
    % ===== 参数显示 =====
    txt_param = uicontrol('Parent', panel, 'Style', 'text', ...
                          'Units', 'pixels', ...
                          'Position', [10 220 180 100], ...
                          'HorizontalAlignment', 'left', 'FontSize', 9, ...
                          'Tag', 'txt_param');
    
    % ===== 坐标轴：保持原布局 =====
    ax1 = subplot(3,2,1); ax2 = subplot(3,2,2);
    ax3 = subplot(3,2,3); ax4 = subplot(3,2,4);
    ax5 = subplot(3,2,[5 6]);
    
    handles.s_fm = s_fm;
    handles.s_fc = s_fc;
    handles.s_Am = s_Am;
    handles.txt_param = txt_param;
    handles.A0 = A0;
    handles.ax1 = ax1;
    handles.ax2 = ax2;
    handles.ax3 = ax3;
    handles.ax4 = ax4;
    handles.ax5 = ax5;
    handles.fig = fig;
    
    guidata(fig, handles);
    
    set(s_fm, 'Callback', @update_plot);
    set(s_fc, 'Callback', @update_plot);
    set(s_Am, 'Callback', @update_plot);
    
    update_plot(fig, []);
end

function update_plot(src, ~)
    if ishandle(src) && strcmp(get(src, 'Type'), 'figure')
        fig = src;
    else
        fig = get(src, 'Parent');
        while ~strcmp(get(fig, 'Type'), 'figure')
            fig = get(fig, 'Parent');
        end
    end
    handles = guidata(fig);
    
    fm = get(handles.s_fm, 'Value');
    fc = get(handles.s_fc, 'Value');
    Am = get(handles.s_Am, 'Value');
    A0 = handles.A0;
    
    mod_index = Am / A0;
    
    if mod_index <= 1
        mod_str = 'Normal AM';
        mod_color = [0 0.5 0];
    else
        mod_str = 'Overmodulation!';
        mod_color = [1 0 0];
    end
    
    set(handles.txt_param, 'String', ...
        sprintf('fm = %.1f Hz\nfc = %.1f Hz\nAm = %.2f\nA0 = %.1f\nm = %.2f\n%s', ...
                fm, fc, Am, A0, mod_index, mod_str), ...
        'ForegroundColor', mod_color);
    
    fs = 2000; T = 0.2;
    t = 0:1/fs:T-1/fs;
    
    m = Am * cos(2*pi*fm*t);
    c = cos(2*pi*fc*t);
    s_am = (A0 + m) .* cos(2*pi*fc*t);
    
    env = abs(s_am);
    [b, a] = butter(4, (2*fm)/(fs/2));
    m_rec = filtfilt(b, a, env);
    m_rec = m_rec - mean(m_rec);
    if max(abs(m_rec)) > 0
        m_rec = m_rec * (Am / max(abs(m_rec)));
    end
    
    plot(handles.ax1, t, m, 'b', 'LineWidth', 1.5);
    title(handles.ax1, 'Modulating Signal m(t)'); grid(handles.ax1, 'on');
    axis(handles.ax1, [0 T -2.5 2.5]);
    
    plot(handles.ax2, t, c, 'r', 'LineWidth', 1);
    title(handles.ax2, 'Carrier c(t)'); grid(handles.ax2, 'on');
    axis(handles.ax2, [0 T -1.5 1.5]);
    
    plot(handles.ax3, t, s_am, 'Color', [0.85 0.33 0.10], 'LineWidth', 1);
    hold(handles.ax3, 'on');
    plot(handles.ax3, t, A0+m, 'k--', 'LineWidth', 1.2);
    plot(handles.ax3, t, -(A0+m), 'k--', 'LineWidth', 1.2);
    hold(handles.ax3, 'off');
    title(handles.ax3, 'AM Signal'); grid(handles.ax3, 'on');
    axis(handles.ax3, [0 T -4 4]);
    
    plot(handles.ax4, t, m, 'b--', 'LineWidth', 1); hold(handles.ax4, 'on');
    plot(handles.ax4, t, m_rec, 'g', 'LineWidth', 1.5); hold(handles.ax4, 'off');
    title(handles.ax4, 'Demodulated vs Original'); grid(handles.ax4, 'on');
    axis(handles.ax4, [0 T -2.5 2.5]);
    legend(handles.ax4, 'Original', 'Demodulated', 'Location', 'northeast');
    
    m_freqs = [-fm, fm];
    m_amps  = [Am/2, Am/2];
    s_freqs = [-fc-fm, -fc, -fc+fm, fc-fm, fc, fc+fm];
    s_amps  = [Am/4, A0/2, Am/4, Am/4, A0/2, Am/4];
    
    stem(handles.ax5, m_freqs, m_amps, 'b', 'LineWidth', 2, 'MarkerSize', 8);
    hold(handles.ax5, 'on');
    stem(handles.ax5, s_freqs, s_amps, 'r', 'LineWidth', 2, 'MarkerSize', 8);
    hold(handles.ax5, 'off');
    
    xlim(handles.ax5, [-fc-2*fm-20, fc+2*fm+20]);
    title(handles.ax5, 'Discrete Spectrum: Modulating (blue) vs AM (red)');
    xlabel(handles.ax5, 'Frequency (Hz)'); ylabel(handles.ax5, 'Magnitude');
    grid(handles.ax5, 'on');
    legend(handles.ax5, 'Modulating', 'AM', 'Location', 'northeast');
end

function overmod_demo(src, ~)
    fig = get(src, 'Parent');
    while ~strcmp(get(fig, 'Type'), 'figure')
        fig = get(fig, 'Parent');
    end
    handles = guidata(fig);
    set(handles.s_Am, 'Value', 2.0);
    update_plot(handles.s_Am, []);
end

function normal_demo(src, ~)
    fig = get(src, 'Parent');
    while ~strcmp(get(fig, 'Type'), 'figure')
        fig = get(fig, 'Parent');
    end
    handles = guidata(fig);
    set(handles.s_Am, 'Value', 1.0);
    update_plot(handles.s_Am, []);
end
