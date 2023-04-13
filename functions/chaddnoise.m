% PURPOSE: add white/pink/line noise to EEG data with specific channels
%
% FORMAT:
%
% [ERPOUT cherror] = chaddnoise(ERPLAB,EEGout,formula,errormsgtype,warningme)
% However syntax is chaddnoise(formula) in eegchanoperator.
%
% INPUT:
%
% EEGin           - input dataset
% EEGout          - output dataset (for recursiveness...)
% formula         - algebraic expression for the (virtual) reference channel
% warningme       - display warnings. 1 yes; 0 no
% errormsgtype    - 1-use popup on error messages, 0-error in red at
%                   command window
%
%
% OUTPUT
%
% ERPout          - re-referenced dataset or erpset
% cherror         - error checking. 0 means no error; 1 means error found
%
%


%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang and Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Apr 2023

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function  [EEGout cherror] = chaddnoise(ERPLAB,EEGout,formula,errormsgtype,warningme)
cherror = 0;

if nargin<3
    help chaddnoise;
    return;
end
if nargin<4
    errormsgtype =1;
    warningme=0;
end

if nargin<5
    warningme=0;
end

if ~iserpstruct(ERPLAB) && ~iseegstruct(ERPLAB)
    error('ERPLAB says: chaddnoise() only works with ERP and EEG structure.')
end
if iseegstruct(ERPLAB)  % EEG
    ntrial    = ERPLAB.trials;
    nchan     = ERPLAB.nbchan;
    datafield = 'data';
    ERPLABaux = [];
    ntrial    = ERPLAB.trials;
else  % ERP
    ntrial    = ERPLAB.nbin;
    nchan     = ERPLAB.nchan;
    datafield = 'bindata';
    ERPLABaux = buildERPstruct([]);
    ntrial = ERPLAB.nbin;
end
% add a dot for .*, ./ and .^ operations
expression = regexprep(formula, '([*/^])', '','ignorecase');%%remove * or ^
formula = regexprep(formula, '([*/^])', '','ignorecase');%%remove * or ^
% looking for eraser command
[materase] = regexpi(expression, '[n]*ch[an]*\d+\s*=\s*\[\]', 'match');

%
% looking for label
%
EEGin = ERPLAB;
[matlabel, toklabel]    = regexpi(expression, '\s*label\s*\=*\s*(.*)', 'match', 'tokens');
if ~isempty(toklabel) && ~isempty(EEGin.chanlocs)
    newlabel   = toklabel{:}{1};
    
    %
    % erase label from expression
    %
    expression = strrep(expression, matlabel{:}, '');
elseif isempty(toklabel) && ~isempty(EEGin.chanlocs)
    newlabel   = 'no_label';
end


%
% Add noise (line,pink, and white)?
%
toklinenoise = regexpi(expression, 'linenoise', 'match','ignorecase');
tokwhitenoise = regexpi(expression, 'whitenoise', 'match','ignorecase');
tokpinknoise = regexpi(expression, 'pinknoise', 'match','ignorecase');

NoiseFlag = [];
if ~isempty(toklinenoise)
    NoiseFlag = 1;
elseif ~isempty(tokwhitenoise)
    NoiseFlag = 2;
elseif  ~isempty(tokpinknoise)
    NoiseFlag = 3;
end

if isempty(NoiseFlag)
    msgboxText= '\n Please define any one of linenoise, whitenoise, or pinknoise.\n';
    title = 'ERPLAB: chaddnoise() error:';
    %errorfound(msgboxText, title);
    if errormsgtype == 1
        errorfound(sprintf(msgboxText), title);
    else
        cprintf('red',msgboxText);
    end
    return;
end


if isempty(toklinenoise) && isempty(tokwhitenoise) && isempty(tokpinknoise)
    ischaddnoise = 0;
else
    ischaddnoise = 1;
end
if isempty(materase)
    
    % looking for ":"
    matint = regexpi(expression, ':ch[an]*', 'match');
    
    if ~isempty(matint)
        error('ERPLAB says: errot at chaddnoise(). Interval of channels is not allowed for deleting process.')
    end
    
    %
    % looking for channel indices
    %
    [mat tok] = regexpi(expression, '[n]*ch[an]*(\d+)', 'match', 'tokens');
    
    if isempty(mat) %&& isavgchan == 0
        
        %
        % ONLY for variable setting (no chans)  ---> send to workspace
        %
        
        %
        % Matlab 7.3 and higher %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        [expspliter, formulasp] = regexp(strtrim(expression), '=','match','split');
        leftsize  =   formulasp{1};
        
        [mater, tok2]  = regexpi(leftsize, '(\w+)', 'match', 'tokens');
        
        if isempty(mater)
            error(['ERPLAB says: errot at chaddnoise(). Formula ' expression ' contains errors.'])
        end
        
        %
        % Sends to workspace your channel definition
        %
        eval(expression)
        
        for j=1:length(mater)
            outvar = char(tok2{j});
            assignin('base', outvar, eval(outvar));
        end
        conti = 1;
        return
    end
    
    nindices  = size(tok,2);
    
    if nindices==0
        msgboxText= '\nChannel indices were not found.\n';
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(msgboxText, title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
    
    chanpos     = zeros(1,nindices);
    realchanpos = chanpos;
    tf = zeros(1,nindices);
    
    for tk=1:nindices
        
        %
        % indices of channels at the formula
        %
        chanpos(tk) = str2num(tok{1,tk}{1,1});
        
        if tk>1
            [tf(tk), realchanpos(tk)] = ismember_bc2(chanpos(tk), 1:EEGin.nbchan);
        else
            [tf(1), realchanpos(1)] = ismember_bc2(chanpos(1), 1:EEGout.nbchan);
        end
    end
    
    %
    % Check right side
    %
    nonexistingchanpos = find([realchanpos(2:end)]==0);
    
    if ~isempty(nonexistingchanpos)
        msgboxText =  ['\nChannel(s) [%s] does not exist!\n'...
            'Only use channels from the list on the right \n'];
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(sprintf(msgboxText, num2str(chanpos(nonexistingchanpos+1))), title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText, num2str(chanpos(nonexistingchanpos+1))), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0; % No more bin processing...
        return
    end
    
    %
    % Keep label (temporary solution...)
    %
    if length(realchanpos(2:end))==1 && strcmp(newlabel, 'no_label')
        newlabel = EEGin.chanlocs(realchanpos(2)).labels;
    end
    
    newchan = chanpos(1);  %this is the formula's left side channel index.
    eraser  = 0;
    
    
else
    %
    % Test nchan sintax (for erasing!?)
    %
    [nchanerase] = regexpi(expression, 'nch[an]*', 'match');
    
    if ~isempty(nchanerase)
        msgboxText=  '\nYou cannot delete a channel using "nchan" sintax\n';
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(msgboxText, title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
    if ischaddnoise % (?)
        msgboxText =  '\nSorry. Adding noise is not yet available for this mode.\n';
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(msgboxText, title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
    
    %
    % look for channel index(ices)
    %
    [mat, tok] = regexpi(expression, 'ch[an]*(\d+)', 'match', 'tokens'); % looking for channel index
    nindices = size(tok,2);
    
    if nindices>2 || nindices<=1
        error('ERPLAB says: errot at chaddnoise(). Two elements of channel index are only included in the Eq. E.g, ch1 = ch1 + whitenoise(1) label FP1');
        
    end
    
    chanpos = zeros(1,nindices);
    
    for tk=1:nindices
        chanpos(tk) = str2double(tok{1,tk}{1,1});  % conteins index of channels in the formula
        [tf, realchanpos(tk)] = ismember_bc2(chanpos(tk), 1:EEGin.nbchan); %#ok<AGROW>
        
        if ~tf(tk)
            msgboxText=  ['\nChannel ' num2str(chanpos(tk)) ' does not  exist yet! \n'];
            title = 'ERPLAB: chaddnoise() error:';
            %errorfound(msgboxText, title)
            if errormsgtype == 1
                errorfound(sprintf(msgboxText), title);
            else
                cprintf('red',msgboxText);
            end
            conti = 0;
            return
        end
    end
    if tk>1
        newchan = chanpos(1):chanpos(2);
    else
        newchan = chanpos(1);
    end
    
    eraser = 1;
end

if isempty(realchanpos) || numel(realchanpos)~=2
    msgboxText = ['ERPLAB says:   Please check your formula:',expression,'.\n\n', ...
        'Two elements of channel index are only included,E.g, ch1 = ch1 + whitenoise(1) label FP1'];
    %      msgboxText =  ['\nPlease, check your formula: \n\n'...
    %             expression '\n' serr.message '\n'];
    title = 'ERPLAB: chaddnoise() error:';
    %errorfound(msgboxText, title)
    if errormsgtype == 1
        errorfound(sprintf(msgboxText), title);
    else
        cprintf('red',msgboxText);
    end
    conti = 0;
    return
end
%
%  Test New Channel
%
lastslot = EEGout.nbchan;

if isempty(lastslot)
    lastslot= 0;
end
if tf(1) && newchan(1)>=1
    if ~eraser
        
        % %             %
        % %             % Gui memory
        % %             %
        % %             wchmsgon = erpworkingmemory('wchmsgon');
        % %
        % %             if isempty(wchmsgon)
        % %                   wchmsgon = 1;
        % %                   erpworkingmemory('wchmsgon',1);
        % %             end
        
        % %             if wchmsgon==0
        % %                   button = 'yes';
        % %             else
        % %                   question = ['Channel %s already exist!\n\n'...
        % %                               'Would you like to overwrite it?'];
        % %                   title    = 'ERPLAB: Overwriting Channel Confirmation';
        % %                   button   = askquest(sprintf(question, num2str(newchan)), title);
        % %             end
        
        if warningme==0
            button = 'yes';
        else
            question = ['Channel %s already exist!\n\n'...
                'Would you like to overwrite it?'];
            title    = 'ERPLAB: Overwriting Channel Confirmation';
            button   = askquest(sprintf(question, num2str(newchan)), title);
        end
        
        if strcmpi(newlabel,'no_label')
            newlabel = EEGin.chanlocs(newchan).labels; % keep the original label
        end
    else
        question = ['Channel %s will be erased!\n\n'...
            'Are you completely sure about this?'];
        title    = 'ERPLAB: Channel Erasing Confirmation';
        button   = askquest(sprintf(question, num2str(newchan)), title);
    end
    if strcmpi(button,'no')
        confirma = 0;
        conti = 0;
        disp(['Channel ' num2str(newchan) ' was not modified'])
    elseif strcmpi(button,'yes')
        confirma = 1;
        %fprintf(['\nWARNING: Channel ' num2str(newchan) ' was overwritten.\n\n'])
    else
        disp('User selected Cancel')
        conti = 0;
        return
    end
elseif (~tf(1) && newchan(1)>=1 && newchan(1) <= lastslot+1)
    confirma = 1;  % Everything is ok!
    realchanpos(1) = lastslot+1;
else
    msgboxText =  ['\nError: Channel ' num2str(newchan) ' is out of order!\n\n'...
        '"chan#" equations must be define in ascending order.\n\n'...
        '"nchan#" equations must be define in ascending order, from 1 to the highest channel. \n'];
    title = 'ERPLAB: chaddnoise:';
    %errorfound(sprintf(msgboxText), title);
    if errormsgtype == 1
        errorfound(sprintf(msgboxText), title);
    else
        cprintf('red',msgboxText);
    end
    conti = 0; % No more bin processing...
    return
end
if confirma
    try
        [mattype toktype] = regexpi(formula, '\s+[\d+]*(whitenoise|linenoise|pinknoise)', 'match','tokens');
        if isempty(mattype) || isempty(toktype)
            msgboxText =  ['\nPlease, check your formula: \n\n'...
                char(formula) '\n'];
            title = 'ERPLAB: chaddnoise() error:';
            if errormsgtype == 1
                errorfound(sprintf(msgboxText), title);
            else
                cprintf('red',msgboxText);
            end
            conti = 0;
            return
        end
        
        %Get the amplitude for noise signal
        AmpNoise = str2num(regexprep(char(mattype{1,1}), char(toktype{1,1}), '','ignorecase'));
        if isempty(AmpNoise)
            AmpNoise = 1;
        end
        
        %%---------------white or pink noise--------------------------------
        if NoiseFlag==2 || NoiseFlag==3%%add white or pink noise
            Noiseedstr = regexpi(formula, ['\s*',char(toktype{1,1}),'\((.*)?\)'], 'tokens','ignorecase');
            
            if isempty(Noiseedstr)
                Noiseed = 0;
            else
                Noiseed = str2num(char(Noiseedstr{1,1}));
            end
            if isempty(Noiseed)
                Noiseed =0;
            end
            trialNum = EEGin.trials;
            sampleNum = EEGin.pnts;
            if Noiseed==0
                rng(1,'twister');
            else
                try
                    rng(Noiseed,'philox');
                catch
                    rng(1,'twister');
                end
            end
            if NoiseFlag ==2%%white noise
                Desirednoise =  randn(1,sampleNum*trialNum);%%white noise
            elseif NoiseFlag ==3%%pink noise
                Desirednoise =  randn(1,sampleNum*trialNum);
                try
                    Desirednoise = pinknoise(sampleNum*trialNum);
                catch
                    Desirednoise = f_pinknoise(sampleNum*trialNum);
                end
            end
            if max(abs(Desirednoise(:)))~=0
                Desirednoise = AmpNoise*Desirednoise./max(abs(Desirednoise(:)));
            end
            Desirednoise = reshape(Desirednoise,sampleNum,trialNum);
            if trialNum==1
                Desirednoise = reshape(Desirednoise,1,sampleNum);
            end
            EEGout.(datafield)(realchanpos(1),:,1:trialNum) = squeeze(EEGin.(datafield)(realchanpos(2),:,1:trialNum))+Desirednoise;
            
        elseif NoiseFlag==1 %%line noise
            
            Periodconstr = regexpi(formula, ['\s*',char(toktype{1,1}),'\((.*)?\)'], 'tokens','ignorecase');
            
            if isempty(Periodconstr)
                msgboxText =  ['\nPlease, define period for line noise, e.g., ch1 = ch1 + 2*linenoise(60) label  FP1;'];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                return;
            else
                Periodcon = str2num(char(Periodconstr{1,1}));
            end
            
            if isempty(Periodcon)
                msgboxText =  ['\nPlease, define period for line noise, e.g., ch1 = ch1 + 2*linenoise(60) label  FP1;'];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                return;
            end
            PeriodValue = Periodcon(1);
            try
                PhaseShit = Periodcon(2);
            catch
                PhaseShit = 0;
            end
            
            trialNum = EEGin.trials;
            sampleNum = EEGin.pnts;
            timeStart = EEGin.xmin;
            timeEnd = EEGin.xmax;
            if trialNum==1
                Times = [timeStart:1/EEGin.srate:timeEnd];
            else
                Times(1) =timeStart;
                for ii = 2:sampleNum*trialNum
                    Times(1,ii)  = Times(1,ii-1)+1/EEGin.srate;
                end
                
            end
            Desirednoise =  AmpNoise*sin(2*PeriodValue*pi*Times+PhaseShit);
            
            Desirednoise = reshape(Desirednoise,sampleNum,trialNum);
            if trialNum==1
                Desirednoise = reshape(Desirednoise,1,sampleNum);
            end
            EEGout.(datafield)(realchanpos(1),:,1:trialNum) = squeeze(EEGin.(datafield)(realchanpos(2),:,1:trialNum))+Desirednoise;
        end
        
        
        %
        % New Label
        %
        if ~isempty(newlabel)
            EEGout.chanlocs(realchanpos(1)).labels = newlabel;
        end
        
        EEGout.nbchan = size(EEGout.data, 1);
        EEGout = eeg_checkset( EEGout );
        disp(['Channel ' num2str(newchan) ' was  created'])
        EEGout = update_rejEfields(EEGin,EEGout,realchanpos);  % update reject fields
        
    catch
        serr = lasterror;
        msgboxText =  ['\nPlease, check your formula: \n\n'...
            expression '\n' serr.message '\n'];
        title = 'ERPLAB: chaddnoise() error:';
        
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
end