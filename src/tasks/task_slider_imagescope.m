function task_slider(hObj)
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            taskinfo_default(hObj, taskinfo)
            handles = guidata(hObj);
            taskinfo = handles.myData.taskinfo;
            taskinfo.rotateback = 0;
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            %generate WSI file and openimage scope
            if strcmp(handles.myData.mode_desc,'Digital')
                wsi_info = handles.myData.wsi_files{taskinfo.slot};
                wsi_scan_scale = handles.myData.settings.scan_scale;
                Left = taskinfo.roi_x-(taskinfo.roi_w/2);
                Top  = taskinfo.roi_y-(taskinfo.roi_h/2);
                exportXML_arrow(wsi_info.fullname,wsi_scan_scale, taskinfo.id,handles.myData.workdir,...
                Left, Top, taskinfo.roi_w, taskinfo.roi_h);
                taskinfo.rotateback = 1;
                myData.taskinfo = taskinfo;
                handles.myData = myData;
                guidata(hObj, handles);
            end
            
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
            initvalue = 50;
            slider_x = .1;
            slider_y = .3;
            slider_w = .6;
            slider_h = .2;
            position = [slider_x, slider_y, slider_w, slider_h];
            handles.slider = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', position, ...
                'Style', 'slider', ...
                'Tag', 'slider', ...
                'String', 'slider_string', ...
                'Min', 0, ...
                'Max', 100, ...
                'SliderStep', [1.0/100.0, .1], ...
                'Value', initvalue, ...
                'Callback', @slider_Callback);

            position = [slider_x+slider_w+.05, slider_y, .1, .2];
            handles.editvalue = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', position, ...
                'Style', 'edit', ...
                'Tag', 'editvalue', ...
                'String', num2str(initvalue), ...
                'KeyPressFcn', @editvalue_KeyPressFcn, ...
                'Callback', @editvalue_Callback);

            position = [slider_x, slider_y+slider_h, .1, .1];
            handles.textleft = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', position, ...
                'Style', 'text', ...
                'Tag', 'textleft', ...
                'String', '0');

            position = [slider_x+slider_w/2-.05, slider_y+slider_h, .1, .1];
            handles.textcenter = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', position, ...
                'Style', 'text', ...
                'Tag', 'textcenter', ...
                'String', '50');

            position = [slider_x+slider_w-.1, slider_y+slider_h, .1, .1];
            handles.textright = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', position, ...
                'Style', 'text', ...
                'Tag', 'textright', ...
                'String', '100');

            position = [slider_x+slider_w+.05, slider_y+slider_h, .1, .1];
            handles.textscore = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', position, ...
                'Style', 'text', ...
                'Tag', 'textright', ...
                'String', 'Score');
            
            uicontrol(handles.editvalue);
            
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback'} % Clean up the task elements

            % Hide image and management buttons
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.slider);
            delete(handles.editvalue);
            delete(handles.textleft);
            delete(handles.textcenter);
            delete(handles.textright);
            delete(handles.textscore);
            handles = rmfield(handles, 'slider');
            handles = rmfield(handles, 'editvalue');
            handles = rmfield(handles, 'textleft');
            handles = rmfield(handles, 'textcenter');
            handles = rmfield(handles, 'textright');
            handles = rmfield(handles, 'textscore');
            
            taskimage_archive(handles);
           
        case 'Save_Results' % Save the results for this task
             
            fprintf(taskinfo.fid, [...
                taskinfo.task, ',', ...
                taskinfo.id, ',', ...
                num2str(taskinfo.order), ',', ...
                num2str(taskinfo.slot), ',',...
                num2str(taskinfo.roi_x), ',',...
                num2str(taskinfo.roi_y), ',', ...
                num2str(taskinfo.roi_w), ',', ...
                num2str(taskinfo.roi_h), ',', ...
                num2str(taskinfo.img_w), ',', ...
                num2str(taskinfo.img_h), ',', ...
                taskinfo.text, ',', ...
                num2str(taskinfo.moveflag), ',', ...
                num2str(taskinfo.zoomflag), ',', ...
                taskinfo.q_op1, ',', ...
                taskinfo.q_op2, ',', ...
                taskinfo.q_op3, ',', ...
                taskinfo.q_op4, ',', ...
                num2str(taskinfo.duration), ',', ...
                num2str(taskinfo.score)]);
            fprintf(taskinfo.fid,'\r\n');
            
    end

    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

function slider_Callback(hObj, eventdata)
try
    
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};

    set(handles.slider, 'BackgroundColor', [.95, .95, .95]);

    score = round(get(hObj, 'Value'));
    set(handles.editvalue, 'String', num2str(score));
    set(handles.NextButton, 'Enable', 'on');
    uicontrol(handles.NextButton);

    taskinfo.score = score;
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
catch ME
    error_show(ME)
end

end

function editvalue_KeyPressFcn(hObj, eventdata)
try
    %--------------------------------------------------------------------------
    % When the text box is non-empty, the user can continue
    %--------------------------------------------------------------------------
    handles = guidata(findobj('Tag','GUI'));
    editvalue_string = eventdata.Key;

    set(handles.slider, ...
        'BackgroundColor', handles.myData.settings.BG_color);

    desc_digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ...
        'delete', 'return', 'backspace'};
    test = max(strcmp(editvalue_string, desc_digits));
    if test
        set(handles.NextButton,'Enable','on');

    else
        desc = 'Input should be an integer';
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        score = round(get(hObj, 'Value'));
        set(handles.editvalue, 'String', num2str(score));
        set(handles.NextButton, 'Enable', 'off');
        uicontrol(handles.editvalue);

        return
    end

catch ME
    error_show(ME)
end

end

function editvalue_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};

    score = str2double(get(handles.editvalue, 'String'));

    if score > 100
        score = 100;
        set(handles.editvalue, 'String', '100');
        set(handles.slider, 'Value', 100);
    elseif score < 0
        score = 0;
        set(handles.editvalue, 'String', '0');
        set(handles.slider, 'Value', 0);
    end
    
    set(handles.slider, ...
        'BackgroundColor', [.95, .95, .95], ...
        'Value', score);
    set(handles.NextButton,'Enable','on');
    uicontrol(handles.NextButton);
    
    % Pack the results
    taskinfo.score = score;
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end

