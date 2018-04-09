%% Connect to Turtlebot
% Connect to an External ROS Master
% ip_robot = '192.168.1.101';     % ip address of tutlebot3, replace this one with yours
% rosinit(ip_robot,'NodeHost','192.168.1.102')


%% read images
% if images captured by Pi camera.
% if you are using Gazebo, the topic list is different.
pi_cam_node = '/raspicam_node/image/compressed';
if ismember(pi_cam_node, rostopic('list'))
    image_sub = rossubscriber(pi_cam_node);
end

%% 
% while(1)

    % Receive image
    image_compressed = receive(image_sub);
    image_compressed.Format = 'bgr8; jpeg compressed bgr8';
    image = readImage(image_compressed);
    % imshow(image)
    
    [YPAng, YPDist, WLDist] = detect_straight_lines(image);

%     pause(1); close all;
    
    % Publish distance info
    
    
% end