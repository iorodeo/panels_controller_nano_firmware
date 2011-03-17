% PanelsNano.m 
%
% Provides a simple interface to the Arduino Nano based panels controller
% enabling the user to set the frame dt in ms. 
%
% Usage:
%  
%  dev = PanelsNano('com5')
%  dev.open()
%  dev.setFrameDt(100)  % Set frame dt to 100ms
%  dev.close()
%
% Author: Will Dickson, IO Rodeo Inc.
% -------------------------------------------------------------------------

classdef  PanelsNano < handle
    
    properties
        dev = [];    
    end
    
    properties (Constant)
        % Serial communications parameters
        baudrate = 9600;
        databits = 8;
        stopbits = 1;
        timeout = 0.5;
        openDelay = 2.0;
    end
    
    methods
        
        function self = PanelsNano(port)
            % Constructor
            if nargin ~= 1
                error('Usage: self = PanelsNano(port)');
            end
            self.dev = serial( ...
                port, ...
                'baudrate', self.baudrate, ...
                'databits', self.databits, ...
                'stopbits', self.stopbits, ...
                'timeout',  self.timeout ...
                );
        end
        
        function open(self)
            % Opens a serial connection to panels controller
            fopen(self.dev);
            pause(self.openDelay);
        end
        
        function close(self)
            % Closes the seraial connection to the panaels controller
            fclose(self.dev);
        end
         
        function setFrameDt(self,dt)
            % Set the frame dt in ms 
            if (dt < 0) || (dt > 255)
                error('frame dt must be between 1 and 255');
            end
            fwrite(self.dev, char(dt));    
        end
      
    end
    
end
