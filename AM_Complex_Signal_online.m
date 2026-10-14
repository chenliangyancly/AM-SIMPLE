function AM_Complex_Signal
% AM 调制解调仿真（复杂信号，Figure 1200×620，5 子图完整显示）

    A0 = 15;
    N_comp = 10;

    fig = figure('Units', 'pixels', ...
                 'Position', [50 50 1200 620], ...
                 'Color', 'w', ...
                 'MenuBar', 'figure', ...
                 'Name', 'AM Modulation (Dense Spectrum)');
    
    % ===== 面板 =====
    panel = uipanel('Parent', fig, 'Title', 'Parameters', ...
                    'Units', 'pixels', ...
                    'Position', [10 10 160 600], ...
                    'FontSize', 10);
    
    % ===== fm 标签 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'fm (0~3 Hz)', ...
              'Units', 'pixels', ...
              'Position', [10 560 140 18], ...
              'HorizontalAlignment', 'left');
    
    % ===== fm 滑块 =====
    s_fm = uicontrol('Parent', panel, 'Style', 'slider', ...
                     'Min', 0, 'Max', 3, 'Value', 1.5, ...
                     'Units', 'pixels', ...
                     'Position', [10 540 140 18], ...
                     'Tag', 's_fm');
    
    % ===== fc 标签 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'fc (Hz)', ...
              'Units', 'pixels', ...
              'Position', [10 505 140 18], ...
              'HorizontalAlignment', 'left');
    
    % ===== fc 滑块 =====
    s_fc = uicontrol('Parent', panel, 'Style', 'slider', ...
                     'Min', 50, 'Max', 200, 'Value', 100, ...
                     'Units', 'pixels', ...
                     'Position', [10 485 140 18], ...
                     'Tag', 's_fc');
    
    % ===== Am 标签 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Am (1~5)', ...
              'Units', 'pixels', ...
              'Position', [10 450 140 18], ...
              'HorizontalAlignment', 'left');
    
    % ===== Am 滑块 =====
    s_Am = uicontrol('Parent', panel, 'Style', 'slider', ...
                     'Min', 1, 'Max', 5, 'Value', 3, ...
                     'Units', 'pixels', ...
                     'Position', [10 430 140 18], ...
                     'Tag', 's_Am');
    
    % ===== A0 固定显示 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', sprintf('A0 = %.1f (fixed)', A0), ...
              'Units', 'pixels', ...
              'Position', [10 395 140 18], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold', 'ForegroundColor', [0 0.4 0.8]);
    
    % ===== 信号说明 =====
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', sprintf('%d components', N_comp), ...
              'Units', 'pixels', ...
              'Position', [10 370 140 18], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9, 'ForegroundColor', [0.5 0.5 0.5]);
    
    % ===== 按钮 =====
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Overmodulation', ...
              'Units', 'pixels', ...
              'Position', [10 330 140 25], ...
              'Callback', @overmod_demo);
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Normal AM', ...
              'Units', 'pixels', ...
              'Position', [10 295 140 25], ...
              'Callback', @normal_demo);
    
    % ===== 参数显示 =====
    txt_param = uicontrol('Parent', panel, 'Style', 'text', ...
                          'Units', 'pixels', ...
                          'Position', [10 180 140 90], ...
                          'HorizontalAlignment', 'left', 'FontSize', 9, ...
                          'Tag', 'txt_param');
    
    % ===== 坐标轴：手动定位 =====
    ax1 = axes('Parent', fig, 'Units', 'pixels', ...
               'Position', [190 450 480 150]);
    ax2 = axes('Parent', fig, 'Units', 'pixels', ...
               'Position', [700 450 480 150]);
    ax3 = axes('Parent', fig, 'Units', 'pixels', ...
               'Position', [190 300 480 140]);
    ax4 = axes('Parent', fig, 'Units', 'pixels', ...
               'Position', [700 300 480 140]);
    ax5 = axes('Parent', fig, 'Units', 'pixels', ...
               'Position', [190 30 990 250]);
    
    handles.s_fm = s_fm;
    handles.s_fc = s_fc;
    handles.s_Am = s_Am;
    handles.txt_param = txt_param;
    handles.A0 = A0;
    handles.N_comp = N_comp;
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
    N_comp = handles.N_comp;
    
    if fm < 0.1
        fm = 0.1;
    end
    
    fk = fm * (1:N_comp) / 2;
    ak = 1 ./ (1:N_comp);
    
    Am_peak = Am * sum(ak);
    mod_index = Am_peak / A0;
    
    if mod_index <= 1
        mod_str = 'Normal AM';
        mod_color = [0 0.5 0];
    else
        mod_str = 'Overmod!';
        mod_color = [1 0 0];
    end
    
    set(handles.txt_param, 'String', ...
        sprintf('fm = %.2f Hz\nfc = %.1f Hz\nAm = %.2f\nA0 = %.1f\nPeak m = %.2f\n%s', ...
                fm, fc, Am, A0, mod_index, mod_str), ...
        'ForegroundColor', mod_color);
    
    T = 0.2;
    N_samples = 8000;
    t = linspace(0, T, N_samples);
    fs = N_samples / T;
    
    m = zeros(size(t));
    for k = 1:N_comp
        m = m + Am * ak(k) * cos(2*pi*fk(k)*t);
    end
    
    c = cos(2*pi*fc*t);
    s_am = (A0 + m) .* cos(2*pi*fc*t);
    
    % 解调
    env = abs(s_am);
    f_max = fk(end);
    f_cut = 1.2 * f_max;
    if f_cut/(fs/2) > 0.9
        f_cut = 0.9 * fs/2;
    end
    [b, a] = butter(2, f_cut/(fs/2));
    m_rec = filtfilt(b, a, env);
    m_rec = m_rec - mean(m_rec);
    if max(abs(m_rec)) > 0
        m_rec = m_rec * (max(abs(m)) / max(abs(m_rec)));
    end
    n_edge = round(0.10 * length(t));
    m_rec(1:n_edge) = m_rec(n_edge+1);
    m_rec(end-n_edge+1:end) = m_rec(end-n_edge);
    
    % 子图 1：复杂调制信号
    plot(handles.ax1, t, m, 'b', 'LineWidth', 1.2);
    title(handles.ax1, 'Dense m(t)', 'FontSize', 10);
    grid(handles.ax1, 'on');
    xlim(handles.ax1, [0 T]); ylim(handles.ax1, [-Am_peak*1.2 Am_peak*1.2]);
    
    % 子图 2：载波
    plot(handles.ax2, t, c, 'r', 'LineWidth', 1);
    title(handles.ax2, 'Carrier c(t)', 'FontSize', 10);
    grid(handles.ax2, 'on');
    xlim(handles.ax2, [0 T]); ylim(handles.ax2, [-1.5 1.5]);
    
    % 子图 3：AM 信号
    plot(handles.ax3, t, s_am, 'Color', [0.85 0.33 0.10], 'LineWidth', 0.8);
    hold(handles.ax3, 'on');
    plot(handles.ax3, t, A0+m, 'k--', 'LineWidth', 1);
    plot(handles.ax3, t, -(A0+m), 'k--', 'LineWidth', 1);
    hold(handles.ax3, 'off');
    title(handles.ax3, 'AM Signal', 'FontSize', 10);
    grid(handles.ax3, 'on');
    xlim(handles.ax3, [0 T]); ylim(handles.ax3, [-A0*1.5 A0*1.5]);
    
    % 子图 4：解调
    plot(handles.ax4, t, m, 'b--', 'LineWidth', 1);
    hold(handles.ax4, 'on');
    plot(handles.ax4, t, m_rec, 'g', 'LineWidth', 1.2);
    hold(handles.ax4, 'off');
    title(handles.ax4, 'Demod vs Original', 'FontSize', 10);
    grid(handles.ax4, 'on');
    xlim(handles.ax4, [0 T]); ylim(handles.ax4, [-Am_peak*1.2 Am_peak*1.2]);
    legend(handles.ax4, 'Orig', 'Demod', 'Location', 'northeast', 'FontSize', 8);
    
    % 子图 5：频谱
    m_freqs = [-fliplr(fk), fk];
    m_amps  = [fliplr(Am*ak/2), Am*ak/2];
    s_freqs_pos = [fc, fc+fk, fc-fk];
    s_amps_pos  = [A0/2, Am*ak/4, Am*ak/4];
    s_freqs = [-fliplr(s_freqs_pos), s_freqs_pos];
    s_amps  = [fliplr(s_amps_pos), s_amps_pos];
    
    stem(handles.ax5, m_freqs, m_amps, 'b', 'LineWidth', 1.2, 'MarkerSize', 4);
    hold(handles.ax5, 'on');
    stem(handles.ax5, s_freqs, s_amps, 'r', 'LineWidth', 1.2, 'MarkerSize', 4);
    hold(handles.ax5, 'off');
    
    xlim(handles.ax5, [-fc-fk(end)-20, fc+fk(end)+20]);
    title(handles.ax5, 'Dense Discrete Spectrum', 'FontSize', 10);
    xlabel(handles.ax5, 'Frequency (Hz)', 'FontSize', 9);
    ylabel(handles.ax5, 'Magnitude', 'FontSize', 9);
    grid(handles.ax5, 'on');
    legend(handles.ax5, 'Mod', 'AM', 'Location', 'northeast', 'FontSize', 8);
end

function overmod_demo(src, ~)
    fig = get(src, 'Parent');
    while ~strcmp(get(fig, 'Type'), 'figure')
        fig = get(fig, 'Parent');
    end
    handles = guidata(fig);
    set(handles.s_Am, 'Value', 5);
    update_plot(handles.s_Am, []);
end

function normal_demo(src, ~)
    fig = get(src, 'Parent');
    while ~strcmp(get(fig, 'Type'), 'figure')
        fig = get(fig, 'Parent');
    end
    handles = guidata(fig);
    set(handles.s_Am, 'Value', 3);
    update_plot(handles.s_Am, []);
end