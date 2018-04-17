%% Connect to Turtlebot
% Connect to an External ROS Master
% ip_robot = '192.168.1.101'; rosinit(ip_robot,'NodeHost','192.168.1.102')
% 


%% read images
% if images captured by Pi camera.
% if you are using Gazebo, the topic list is different.
pi_cam_node = '/raspicam_node/image/compressed';
if ismember(pi_cam_node, rostopic('list'))
    image_sub = rossubscriber(pi_cam_node);
end

camPub = rospublisher('/telemetry', 'geometry_msgs/Twist');
camMsg = rosmessage(camPub);

%% 
while(1)

    % Receive image
    image_compressed = receive(image_sub);
    image_compressed.Format = 'bgr8; jpeg compressed bgr8';
    image = readImage(image_compressed);
    % imshow(image)
    
    [YPDist, YPAng , IsArrieved, WLDist, WLAng, WLAng2] = detect_straight_lines(image);
    
    % Publish distance & angle info 

    
    % assign linear velocity
    camMsg.Linear.X = YPDist;
    camMsg.Linear.Y = YPAng;
    camMsg.Linear.Z = IsArrieved;
    % assign angular velocity
    camMsg.Angular.X = WLDist;
    camMsg.Angular.Y = WLAng;
    camMsg.Angular.Z = WLAng2;
    send(camPub, camMsg);
    
    info = [YPDist, YPAng , IsArrieved, WLDist, WLAng, WLAng2];
    disp(info);
    
    pause(0.5); close all;
    
end