
import 'package:flutter/material.dart';
import 'package:hermes/FloatButton.dart';
import 'package:hermes/FullCoverOpaque.dart';
import 'package:provider/provider.dart';

import '../../CardColumnWidget.dart';
import 'FloorRoomModel.dart';

class FloorRoomsPage extends StatefulWidget {


  @override
  _FloorRoomsPageState createState() => _FloorRoomsPageState();
}



class _FloorRoomsPageState extends State<FloorRoomsPage> {

  final ScrollController _scrollController = ScrollController();

  bool _addRoom=false;


  Widget roomBuilder(){
    var roomModel=Provider.of<FloorRoomModel>(context);
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemBuilder: (context,index){
        var room = roomModel.rooms[index];
        var fee=roomModel.getFee(room);
        var key = ObjectKey(room.name);
        return ListTile(
          key: key,
          isThreeLine: true,
          subtitle: Text(fee==null?"placeholder":"${fee.rent??0}  ${fee.electFee??0}元/度   ${fee.waterFee??0}元/升"),
          title: Text(
            room.name,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(fontSize: 18.0),
          ),
          onTap: () => roomModel.enterRoom(context,room),
        );
      },
      itemCount: roomModel.rooms.length,
      itemExtent: 60,
      physics: ClampingScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var roomModel=Provider.of<FloorRoomModel>(context);
    List<Widget> widgets=[
      Scaffold(
        appBar: AppBar(
          title: Text(roomModel.floor.name),
        ),
        floatingActionButton: FloatButton(
          onPressed: ()=> setState(() => _addRoom=true),
        ),
        body: roomBuilder(),
      )

    ];
    if(_addRoom){
      widgets.add(FullCoverOpaque());
      widgets.add(inputFloorWidget());
    }

    return Stack(

      children: widgets,
    );
  }


  Widget inputFloorWidget() {
    print("object");
    var roomModel=Provider.of<FloorRoomModel>(context,listen: false);
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom ),
      child: CardColumnWidget(
          child: Container(
            height: 160,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.lightBlue,
                            ),
                            child: IconButton(
                                icon: Icon(Icons.close,color: Colors.white),
                                onPressed: ()=>setState(()=>_addRoom=false)
                            ),
                          ),
                        )
                    ),

                    Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: FlatButton(
                              onPressed: (){
                                _addRoom=false;
                                roomModel.addRoom(context);

                              },
                              child: Text("ADD",
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 18
                                ),
                              )
                          ),
                        )
                    ),
                  ],
                ),
                TextField(
//                    onSubmitted: (s) {},
                  controller: roomModel.roomNameController,
                  autofocus: true,
                  maxLines: 1,
                  obscureText: false,
                  decoration: InputDecoration(labelText: "套间名", icon: Icon(Icons.atm)),
                ),
                /*TextField(
                  controller: _roomSortController,
                  autofocus: false,
                  maxLines: 1,
                  obscureText: false,
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      labelText: "排序(不填默认99)", icon: Icon(Icons.access_time)),
                ),*/
              ],
            ),
          )
      ),
    );
  }


}
