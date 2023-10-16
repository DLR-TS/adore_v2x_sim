/****************************************************************************/
// Eclipse ADORe, Automated Driving Open Research; see https://eclipse.org/adore
// Copyright (C) 2017-2020 German Aerospace Center (DLR).
// This program and the accompanying materials
// are made available under the terms of the Eclipse Public License v2.0
// which accompanies this distribution, and is available at
// http://www.eclipse.org/legal/epl-v20.html
// SPDX-License-Identifier: EPL-2.0
/****************************************************************************/
/// @file    channel_sim_node.cpp
/// @author  Daniel Heß
/// @contact Daniel.Hess@DLR.de
/// @date 2020/04/02
/// @initialrelease X.X.X
///
// channel_sim_node realizes v2x error model and transmission of messages 
// to/from a single station.

#include <ros/ros.h>
#include <adore_v2x_sim/SimSPATEM.h>
#include <adore_v2x_sim/SimMAPEM.h>
#include <adore_v2x_sim/SimMCM.h>
#include <adore_v2x_sim/SimDENM.h>
#include <adore_v2x_sim/SimSREM.h>


#include <adore_v2x_sim/channel2station.h>


int main(int argc,char **argv)
{
    ros::init(argc,argv,"channel_sim_node");
    ros::NodeHandle n;
    adore_v2x_sim::Station station(n,"odom");
    adore_v2x_sim::Channel channel(n,&station,0);
    adore_v2x_sim::ChannelToStation<adore_v2x_sim::SimSPATEM,
                                 adore_v2x_sim::SimSPATEMConstPtr,
                                 dsrc_v2_spatem_pdu_descriptions::SPATEM,
                                 dsrc_v2_spatem_pdu_descriptions::SPATEMConstPtr>
                                channelToStation_spatem(n,
                                    "/SIM/v2x/SPATEM",
                                    "/SIM/v2x/SPATEM",
                                    "v2x/incoming/SPATEM",
                                    "v2x/outgoing/SPATEM",
                                    &station,
                                    &channel
                                    );
    adore_v2x_sim::ChannelToStation<adore_v2x_sim::SimMAPEM,
                                 adore_v2x_sim::SimMAPEMConstPtr,
                                 dsrc_v2_mapem_pdu_descriptions::MAPEM,
                                 dsrc_v2_mapem_pdu_descriptions::MAPEMConstPtr>
                                channelToStation_mapem(n,
                                    "/SIM/v2x/MAPEM",
                                    "/SIM/v2x/MAPEM",
                                    "v2x/incoming/MAPEM",
                                    "v2x/outgoing/MAPEM",
                                    &station,
                                    &channel
                                    );
    adore_v2x_sim::ChannelToStation<adore_v2x_sim::SimMCM,
                                     adore_v2x_sim:: SimMCMConstPtr,
                                    mcm_dmove::MCM,
                                    mcm_dmove::MCMConstPtr>
                                    channelToStation_mcm(n,
                                        "/SIM/v2x/MCM",
                                        "/SIM/v2x/MCM",
                                        "v2x/incoming/MCM",
                                        "v2x/outgoing/MCM",
                                    &station,
                                    &channel
                                    );
    adore_v2x_sim::ChannelToStation<   adore_v2x_sim::SimDENM,
                                adore_v2x_sim::SimDENMConstPtr,
                                denm_v2_denm_pdu_descriptions::DENM,
                                denm_v2_denm_pdu_descriptions::DENMConstPtr  >
                                channelToStation_denm(n,
                                    "/SIM/v2x/DENM",
                                    "/SIM/v2x/DENM",
                                    "v2x/incoming/DENM",
                                    "v2x/outgoing/DENM",
                                &station,
                                &channel
                                );
    adore_v2x_sim::ChannelToStation<   adore_v2x_sim::SimSREM,
                                adore_v2x_sim::SimSREMConstPtr,
                                dsrc_v2_srem_pdu_descriptions::SREM,
                                dsrc_v2_srem_pdu_descriptions::SREMConstPtr  >
                                channelToStation_srem(n,
                                    "/SIM/v2x/SREM",
                                    "/SIM/v2x/SREM",
                                    "v2x/incoming/SREM",
                                    "v2x/outgoing/SREM",
                                &station,
                                &channel
                                );

    ros::spin();
    return 0;
}
