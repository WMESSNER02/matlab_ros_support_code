function [res,state] = doGrip(type)
%--------------------------------------------------------------------------
% Tell gripper to either pick or place via the ros gripper action client
%
% Input: type (string) - 'pick' or 'place'
% Output: actoin result and state
%--------------------------------------------------------------------------

    %% Create a gripper action client
    grip_action_client = rosactionclient('/gripper_controller/follow_joint_trajectory', ...
                                          'control_msgs/FollowJointTrajectory',...
                                          'DataFormat','struct');
    
    % Create a gripper goal action message
    grip_msg = rosmessage(grip_action_client);

    %% Testing if setting FeedbackFcn to 0 minimizes the loss connection
    grip_action_client.FeedbackFcn = []; 

    %% Set Grip Pos by default to pick / close gripper
    gripPos = 0.23; % 0.225 for upright cans tends to slip. 

    if nargin==0
        type = 'pick';
    end

    % Modify it if place (i.e. open)
    if strcmp(type,'place')
        gripPos = 0;           
    end

    %% Pack gripper information intro ROS message
    grip_goal = packGripGoal_struct(gripPos,grip_msg);

    %% Send action goal
    disp('Sending grip goal...');

    if waitForServer(grip_action_client)
        disp('Connected to action server. Sending goal...')
        [res,state,status] = sendGoalAndWait(grip_action_client,grip_goal);
    else
        % Re-attempt
        disp('First try failed... Trying again...');
        [res,state,status] = sendGoalAndWait(grip_action_client,grip_goal);
    end    

    %% Clear grip_action_client: checking to see if this minimizes ROS network connection errors
    clear grip_action_client;
end