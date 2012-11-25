#ifndef _IGF_H
#define _IGF_H

#include "ip.h"
#include "main.h"
#include "nwcommon.h"

typedef struct RTEntry
{
    NODE_ADDR destAddr;
    struct RTEntry *next;
} IGF_RT_Node;

typedef struct
{
    IGF_RT_Node *head;
    int size;
} IGF_RT;

typedef struct IGF_NT_entry {
  NODE_ADDR 	 neighborID;
  GlomoCoordinates neighborPosition;
  BOOL 	refreshStatus;
  BOOL 	neighborStatus;  
  struct IGF_NT_entry *next;
} IGF_NT_ENTRY;

typedef struct {
  IGF_NT_ENTRY *head;
  int size;
} IGF_NT;

typedef struct IGF_LOCATION_SERVICE_entry {
  NODE_ADDR		nodeAddr;
  GlomoCoordinates	position;
  struct IGF_LOCATION_SERVICE_entry *next;
} IGF_LOCATION_SERVICE_ENTRY;

typedef struct {
  IGF_LOCATION_SERVICE_ENTRY *head;
  int size;
} IGF_LOCATION_SERVICE_TABLE;

typedef enum {
  IGF_PACKET_TYPE_BEACON
} IGF_PACKET_TYPE;

typedef struct {
  IGF_PACKET_TYPE packetType;
  NODE_ADDR nodeID;
  GlomoCoordinates nodePosition; 
} IGF_BEACON_PACKET;

typedef struct{
  int	packet_send;
  int	packet_recv;
  int	numOfBeaconPkts;
} IGF_STATS;

typedef struct {	
  IGF_NT     nt;
  NODE_ADDR nodeID;
  GlomoCoordinates nodePosition;
  int	seqNO;
  clocktype beacon_interval;
  IGF_STATS stats;
  int  SenderSeqNO;
  int  numBeacons;
  IGF_RT routeTable;
  
} GlomoRoutingIGF;

void RoutingIGFInit(GlomoNode *node, 
		   GlomoRoutingIGF **IGFPtr, 
		   const GlomoNodeInput *nodeInput);

void IGF_ScheduleABeacon(GlomoNode *node);

void IGF_SendABeacon(GlomoNode * node);

void RoutingIGFFinalize(GlomoNode *node);

void RoutingIGFHandleProtocolPacket(GlomoNode *node, Message *msg, 
				   NODE_ADDR srcAddr, 
				   NODE_ADDR destAddr);

void RoutingIGFHandleProtocolEvent(GlomoNode *node, Message *msg);

void IGF_InitStats(GlomoNode * node);

void RoutingIGFRouterFunction(GlomoNode *node,
			     Message *msg,
			     NODE_ADDR destAddr,
			     BOOL *packetWasRouted);
   
void IGF_AddAEntryIntoNT(IGF_NT * nt, IGF_NT_ENTRY *newEntry);

void IGF_InitNT(IGF_NT * nt);

void IGF_PrintNT(GlomoNode * node, IGF_NT * nt);
    
void IGF_HandleABeaconPacket(GlomoNode * node, Message* msg);
    
void IGF_MakeRoutingDecision(GlomoNode *	node, 
			    Message * msg, NODE_ADDR destAddr);

NODE_ADDR IGF_GetNextHop(IGF_NT *nt, GlomoNode * node, NODE_ADDR destAddr);

double IGF_GetDistance(GlomoCoordinates sourceAddr, GlomoCoordinates destAddr);

// delay the time to start the first beacon schedule
void IGF_Enable_ScheduleABeacon(GlomoNode *node);

GlomoCoordinates IGF_GetPosition(NODE_ADDR node);

void 	IGF_LocServ_Init();
void	IGF_LocServ_AddEntry(GlomoNode *node);
GlomoCoordinates IGF_LocServ_Lookup(NODE_ADDR nodeAddr);


#endif /* _IGF_H */
