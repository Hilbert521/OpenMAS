%% OPENMAS EVENT HANDLER (OMAS_eventHandler.m) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is designed to handle an event occuring between objectA and
% objectB. An EVENT object is created at the current time, based on the two 
% objects and the enumerated event type. 

% Author: James A. Douthwaite 06/10/17

function [metaObjectA,EVENT] = OMAS_eventHandler(SIM,metaObjectA,metaObjectB,eventEnumeration)
% INPUTS:
% SIM                - A snapshot of the META data
% - TIME.currentTime - Current simulation time
% - OBJECTS          - The current OBJECTS META set
% metaobjectA        - The reference object (entity or meta)
% metaobjectB        - The detected/collision object (entity or meta)
% eventEnumeration   - The type of event indicated by the simulator

% OUTPUTS:
% modifiedMETAobject - The META.OBJECT copy, updated with event history
% EVENT              - The generated detection event structure

% INPUT HANDLING
if ~exist('eventEnumeration','var')
    error('[ERROR]\tEvent "type" unspecified.\n'); 
end

% DETERMINE THE AVAILABLE META DATA FOR objectA
currentTime = SIM.TIME.currentTime;             % Current timestep
% GET THE SIM.OBJECT INDEX FROM THE metaObjectB.ID
METAindex = find(SIM.globalIDvector == metaObjectB.objectID);

%% GENERATE THE APPROPRIATE EVENT CLASS
% The simulation will generate one of the following events inreponse to the
% request. The result is an event object and the associated updated meta
% object.
switch eventEnumeration
% DETECTION EVENTS    
    case eventType.detection
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.detection) = 1;       % Ammend status of the META object
        % BUILD EVENT OBJECT
        infoString = sprintf('Detection notification [%s:%s].',metaObjectA.name,metaObjectB.name);
        EVENTobj = detectionEvent(currentTime,metaObjectA,metaObjectB,infoString);
% DETECTION-LOSS EVENTS    
    case eventType.null_detection
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.detection) = 0;       % Ammend status of the META object
        % BUILD EVENT OBJECT
        infoString = sprintf('Detection-loss notification [%s:%s].',metaObjectA.name,metaObjectB.name);
        EVENTobj = detectionEvent(currentTime,metaObjectA,metaObjectB,infoString,eventType.null_detection);

 % WARNING/NEAR-MISS EVENTS
    case eventType.warning
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.warning) = 1;
        % BUILD EVENT OBJECT
        infoString = sprintf('Proximity warning notification [%s:%s].',metaObjectA.name,metaObjectB.name);
        EVENTobj = warningEvent(currentTime,metaObjectA,metaObjectB,infoString);
    
% A WARNING/NEAR MISS CONDITION NULLIFICATION
    case eventType.null_warning        
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.warning) = 0;
        % BUILD EVENT OBJECT
        infoString = sprintf('Proximity warning-clear notification [%s:%s].',metaObjectA.name,metaObjectB.name);
        EVENTobj = warningEvent(currentTime,metaObjectA,metaObjectB,infoString,eventType.null_warning);

% COLLISION/GEOMETRIC VIOLATION EVENTS
    case eventType.collision
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.collision) = 1;
        % BUILD EVENT OBJECT
        infoString = sprintf('Collision notification [%s:%s]',metaObjectA.name,metaObjectB.name);
        EVENTobj = collisionEvent(currentTime,metaObjectA,metaObjectB,infoString);

% COLLISION/GEOMETRIC VIOLATION NULLIFICATION EVENTS        
    case eventType.null_collision
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.collision) = 0;
        % BUILD EVENT OBJECT
        infoString = sprintf('Collision-clear notification [%s:%s]',metaObjectA.name,metaObjectB.name);
        EVENTobj = collisionEvent(currentTime,metaObjectA,metaObjectB,infoString,eventType.null_collision);       
    
% WAYPOINT ACHIEVED EVENTS   
    case eventType.waypoint
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.waypoint) = 1;
        % BUILD EVENT OBJECT
        infoString = sprintf('Waypoint notification [%s:%s]',metaObjectA.name,metaObjectB.name);
        EVENTobj = waypointEvent(currentTime,metaObjectA,metaObjectB,infoString);

% WAYPOINT-LOSS EVENTS
    case eventType.null_waypoint
        % AMEND THE META OBJECT
        metaObjectA.objectStatus(METAindex,eventType.waypoint) = 0;
        % A WAYPOINT RESET EVENT (NON-WAYPOINT)
%         infoString = sprintf('Waypoint-reset notification [%s:%s]',metaObjectA.name,metaObjectB.name);
%         EVENTobj = waypointEvent(METAObjectID,metaObjectB,infoString,eventType.null_waypoint);
        EVENTobj = [];

    % EVENT UNKNOWN    
    otherwise
        warning('[ERROR] Event "type" not recognised.');
        EVENT = [];
        return
end
% OUTPUT EVENT STRUCTURE
EVENT = []; 
% CONVERT THE EVENT OBJECT INTO A REPORT STRUCTURE
if ~isempty(EVENTobj)
    % GENERATE THE SIMULATION EVENT STRUCTURE
    [EVENT] = event2Struct(EVENTobj);
    % IF VERBOSE, GENERATE NOTIFICATION OF EVENT CREATION
    if SIM.verboseMode
        fprintf('[%s]\tevent created (ID:%s @%ss):\t%s\n',EVENTobj.name,num2str(EVENTobj.eventID),num2str(EVENTobj.time),EVENTobj.info);
    end
end
end

% GENERATE EVENT RECORD
function [EVENT] = event2Struct(EVENTobject)
% This function converts the event object into a structure for the
% simulation log.
% INPUT
% EVENTobject - The EVENT class object
% OUTPUT
% EVENT       - The EVEN log structure

% Append EVENT CLASS TO STRUCTURE FOR REPORTING
EVENT = struct('eventID',EVENTobject.eventID,...
                  'time',EVENTobject.time,...
                  'type',EVENTobject.type,...
                  'name',EVENTobject.name,...
            'objectID_A',EVENTobject.objectID_A,...
                'name_A',EVENTobject.name_A,...
               'state_A',EVENTobject.state_A,...
            'objectID_B',EVENTobject.objectID_B,...
                'name_B',EVENTobject.name_B,...
               'state_B',EVENTobject.state_B,...    
            'seperation',EVENTobject.seperation,...
                  'info',EVENTobject.info);               
clear EVENTobject 
end