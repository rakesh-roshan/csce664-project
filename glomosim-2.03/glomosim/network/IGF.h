#ifndef _IGF_H
#define _IGF_H

#include "ip.h"
#include "main.h"
#include "nwcommon.h"

typedef struct RTEntry
{
    NODE_ADDR destAddr;
    NODE_ADDR nextHop;
    struct RTEntry *next;
} IGF_RT_Node;

typedef struct
{
    IGF_RT_Node *head;
    int size;
} IGF_RT;

typedef struct IGF_LOCATION_SERVICE_entry {
  NODE_ADDR		nodeAddr;
  GlomoCoordinates	position;
  struct IGF_LOCATION_SERVICE_entry *next;
} IGF_LOCATION_SERVICE_ENTRY;

typedef struct {
  IGF_LOCATION_SERVICE_ENTRY *head;
  int size;
} IGF_LOCATION_SERVICE_TABLE;

typedef struct{
  int	packet_send;
  int	packet_recv;
  int	numOfBeaconPkts;
} IGF_STATS;

typedef struct {	
  NODE_ADDR nodeID;
  GlomoCoordinates nodePosition;
  int	seqNO;
  IGF_STATS stats;
  int  SenderSeqNO;
  IGF_RT routeTable;
  
} GlomoRoutingIGF;

void RoutingIGFInit(GlomoNode *node, 
		   GlomoRoutingIGF **IGFPtr, 
		   const GlomoNodeInput *nodeInput);

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
   
void IGF_MakeRoutingDecision(GlomoNode *	node, 
			    Message * msg, NODE_ADDR destAddr);

NODE_ADDR IGF_GetNextHop(IGF_RT *rt, GlomoNode * node, NODE_ADDR destAddr);

double IGF_GetDistance(GlomoCoordinates sourceAddr, GlomoCoordinates destAddr);

GlomoCoordinates IGF_GetPosition(NODE_ADDR node);

void 	IGF_LocServ_Init();
void	IGF_LocServ_AddEntry(GlomoNode *node);
GlomoCoordinates IGF_LocServ_Lookup(NODE_ADDR nodeAddr);

int IGF_GetRouteRecord(Message * msg,NODE_ADDR* nodesarray);
void IGF_UpdateRoutingTable(GlomoNode *node,NODE_ADDR destaddr,NODE_ADDR nexthop);
void IGF_AddEntryIntoRT(IGF_RT *rt, IGF_RT_Node *newrtEntry);
NODE_ADDR IGF_GetFinalDestAddr(Message *msg);
#endif /* _IGF_H */
