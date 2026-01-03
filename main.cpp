/*
 * @Function:Using Ego Planner to Generate Trajectory
 * @Create by:juchunyu@qq.com
 * @Date:2025-08-02 18:58:01
 */
#include <iostream> 
#include <string>    
#include <ios>     
#include <vector>
#include <fstream>

#include "planner_interface.h"

using namespace ego_planner;


int main()
{
    std::vector<double> global_x;
    std::vector<double> global_y;

    std::vector<double> local_plan_x;
    std::vector<double> local_plan_y;

    std::vector<double> obs_x;
    std::vector<double> obs_y;
    std::vector<double> color;

    std::shared_ptr<PlannerInterface>  plan = std::make_shared<PlannerInterface>();
    
    //初始化控制参数
    double max_vel = 1.0;
    double max_acc = 1.0;
    double max_jerk = 1.0;
    plan->initParam(max_vel,max_acc,max_jerk);

    //初始化ESDF地图
    double resolution = 0.1;
    double x_size = 10.0;
    double y_size = 10.0;
    double z_size = 10.0;
    Eigen::Vector3d origin(0.0, 0.0, 0.0);
    double inflateValue = 0.0;
    plan->initEsdfMap(x_size,y_size,z_size,resolution,origin,inflateValue);
  
    //添加障碍物点云
    std::vector<ObstacleInfo> obstacle;
    ObstacleInfo Obstemp;
    Obstemp.x = 6;
    Obstemp.y = 6;
    obstacle.push_back(Obstemp);
    Obstemp.x = 3.0;
    Obstemp.y = 3.0;
    obstacle.push_back(Obstemp);

    plan->setObstacles(obstacle);

    //添加全局路径点
    std::vector<PathPoint> global_plan_traj;
    
    global_x.clear();
    global_y.clear();

    float j = 0;

    while(j < 10)
    {
        PathPoint tempPoint;
        tempPoint.x = j;
        tempPoint.y = j;

        global_plan_traj.push_back(tempPoint);
  
        j+= 0.1;
        global_x.push_back(j);
        global_y.push_back(j);
    }


    plan->setPathPoint(global_plan_traj);

    
    //开始规划
    plan->makePlan();
    
    //获取规划结果
    std::vector<PathPoint> plan_traj_res;
    plan->getLocalPlanTrajResults(plan_traj_res);
    
    // 输出规划结果到控制台
    std::cout << "Ego Planner Results!" << std::endl;
    std::cout << "Global trajectory points: " << global_plan_traj.size() << std::endl;
    std::cout << "Local optimized trajectory points: " << plan_traj_res.size() << std::endl;
    std::cout << "Obstacles: " << obstacle.size() << std::endl;
    
    // 输出部分规划结果
    std::cout << "\nLocal trajectory sample points: " << std::endl;
    for(int i = 0; i < std::min(10, (int)plan_traj_res.size()); i++)
    {
        std::cout << "Point " << i << ": x=" << plan_traj_res[i].x << ", y=" << plan_traj_res[i].y << std::endl;
    }
    
    if(plan_traj_res.size() > 10)
    {
        std::cout << "... and " << plan_traj_res.size() - 10 << " more points" << std::endl;
    }

    // 将结果写入 CSV 以便可视化 (type,x,y) -- type: G=global, L=local, O=obstacle
    std::ofstream ofs("trajectory.csv");
    if(ofs.is_open()){
        ofs << "type,x,y\n";
        for(const auto &p: global_plan_traj){
            ofs << "G," << p.x << "," << p.y << "\n";
        }
        for(const auto &p: plan_traj_res){
            ofs << "L," << p.x << "," << p.y << "\n";
        }
        for(const auto &o: obstacle){
            ofs << "O," << o.x << "," << o.y << "\n";
        }
        ofs.close();
        std::cout << "Wrote trajectory to trajectory.csv\n";
    } else {
        std::cerr << "Failed to write trajectory.csv" << std::endl;
    }


    return 0;
}