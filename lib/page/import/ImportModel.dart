import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/page/Rebuild.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class ImportModel extends ChangeNotifier{

  int way=0;

  int progress=0;

  bool importing=false;



  Future<void> importOldVerData(String content) async{
    Map<String,dynamic> json = jsonDecode(utf8.decode(GZipDecoder().decodeBytes(base64.decode(content))));
    Printer.printMapJsonLog(json);
    importing=true;
    progress=0;
    notifyListeners();
    await Rebuild(MapKv(json)).start();
  }

  Future<void> importNewVerData(File dbFile)async{
    importing=true;
    progress=0;
    notifyListeners();
    return App.switchDatabase(dbFile);
  }

  Future<void> importConfig(String text) async {
    try {
      if(way==1){
            var file = new File(text);
            if(!await file.exists())
              return;
            if(file.path.endsWith("hermes.db")){
              await importNewVerData(file);
            }else{
              var str=await file.readAsString();
              await importOldVerData(str);
            }
          }else{
            await importOldVerData(text);
          }
    } catch (e) {
      Printer.error(e);
      importing=false;
      notifyListeners();
      throw e;
    }
  }

  Future<String?> getEncryptData(String text) async{
    if(way==1){
      try {
        var file = new File(text);
        if(! await file.exists())
          return null;
        var str=await file.readAsString();
        return str;
      } catch (e) {
        return null;
      }
    }
    return text;
  }


  void setWay(int value){
    way=value;
    notifyListeners();
  }

  int get index => progress;
}
//eyLov5nkuKrlkow6b3B0aW9uOmZlZSI6Ilt7XCJuYW1lXCI6XCLmpbzmoq/otLlcIixcImZlZVwiOjQuMH1dIiwiaGVybWVzOmZsb29yOisxIjoiW3tcIm5hbWVcIjpcIueahOWTh+WTplwiLFwic29ydFwiOjk5fV0iLCJoZW1lcnM6Zmxvb3JzIjoiW3tcIm5hbWVcIjpcIjFcIixcInNvcnRcIjo5OX0se1wibmFtZVwiOlwiMlwiLFwic29ydFwiOjk5fSx7XCJuYW1lXCI6XCJhXCIsXCJzb3J0XCI6OTl9LHtcIm5hbWVcIjpcImJcIixcInNvcnRcIjo5OX0se1wibmFtZVwiOlwi5L2g5aaIXCIsXCJzb3J0XCI6OTl9LHtcIm5hbWVcIjpcIuWVilwiLFwic29ydFwiOjk5fSx7XCJuYW1lXCI6XCLlm5vmpbxcIixcInNvcnRcIjowfSx7XCJuYW1lXCI6XCLnmoRcIixcInNvcnRcIjo5OX0se1wibmFtZVwiOlwi55qE5ZOH55qE5ZOHXCIsXCJzb3J0XCI6OTl9LHtcIm5hbWVcIjpcIuiNieS7luS7rOeahOWTh+eahFwiLFwic29ydFwiOjk5fV0iLCLov5nkuKrlkoxfTEFTVF9TRUxFQ1QiOiIyMDIwLTEyLTA1Iiwi6L+Z5Liq5ZKMOmZlZSI6IntcInJlbnRcIjozMC4wLFwiZWxlY3RGZWVcIjoxLjAsXCJ3YXRlckZlZVwiOjIuMH0iLCLov5nkuKrlkow6ZGF0ZToyMDIwLTEyLTA1Ijoie1wiZGF0ZVwiOlwiMjAyMC0xMi0wNSAxMTo1NTo1NS42MDExNDJcIixcImVsZWN0XCI6OTAsXCJ3YXRlclwiOjEwMH0iLCLov5nkuKrlkow6cm9vbTpmZWU6c25hcHNob3Q6MjAyMC0xMi0wMiI6IntcImRhdGVcIjpcIjIwMjAtMTItMDJcIixcImVsZWN0RmVlXCI6MS4wLFwid2F0ZXJGZWVcIjoyLjAsXCJyZW50XCI6MzAuMCxcInRvdGFsXCI6OTQuMCxcIml0ZW1zXCI6W3tcIm5hbWVcIjpcIueUtei0uVwiLFwiZGVzY1wiOlwiNTAgLSAxMCA9IDQwIOW6plxcbjQwICogMS4wID0gNDAuMCDlhYNcIixcImZlZVwiOjQwLjB9LHtcIm5hbWVcIjpcIuawtOi0uVwiLFwiZGVzY1wiOlwiNDAgLSAzMCA9IDEwIOWNh1xcbjEwICogMi4wID0gMjAuMCDlhYNcIixcImZlZVwiOjQwLjB9LHtcIm5hbWVcIjpcIuenn+mHkVwiLFwiZGVzY1wiOm51bGwsXCJmZWVcIjozMC4wfSx7XCJuYW1lXCI6XCLmpbzmoq/otLlcIixcImRlc2NcIjpudWxsLFwiZmVlXCI6NC4wfSx7XCJuYW1lXCI6XCLmgLvmlLbotLlcIixcImRlc2NcIjpudWxsLFwiZmVlXCI6OTQuMH1dfSIsImhlcm1lczpmbG9vcjor5Zub5qW8IjoiW3tcIm5hbWVcIjpcIui/meS4quWSjFwiLFwic29ydFwiOjk5fV0iLCLov5nkuKrlkow6ZGF0ZToyMDIwLTEyLTAyIjoie1wiZGF0ZVwiOlwiMjAyMC0xMi0wMiAxMzoxNjowMy4yNzQ1OTFcIixcImVsZWN0XCI6NTAsXCJ3YXRlclwiOjQwfSIsIui/meS4quWSjDpyb29tOmZlZTpzbmFwc2hvdDoyMDIwLTEyLTA1Ijoie1wiZGF0ZVwiOlwiMjAyMC0xMi0wNVwiLFwiZWxlY3RGZWVcIjoxLjAsXCJ3YXRlckZlZVwiOjIuMCxcInJlbnRcIjozMC4wLFwidG90YWxcIjoxOTQuMCxcIml0ZW1zXCI6W3tcIm5hbWVcIjpcIueUtei0uVwiLFwiZGVzY1wiOlwiOTAgLSA1MCA9IDQwIOW6plxcbjQwICogMS4wID0gNDAuMCDlhYNcIixcImZlZVwiOjQwLjB9LHtcIm5hbWVcIjpcIuawtOi0uVwiLFwiZGVzY1wiOlwiMTAwIC0gNDAgPSA2MCDljYdcXG42MCAqIDIuMCA9IDEyMC4wIOWFg1wiLFwiZmVlXCI6NDAuMH0se1wibmFtZVwiOlwi56ef6YeRXCIsXCJkZXNjXCI6bnVsbCxcImZlZVwiOjMwLjB9LHtcIm5hbWVcIjpcIualvOair+i0uVwiLFwiZGVzY1wiOm51bGwsXCJmZWVcIjo0LjB9LHtcIm5hbWVcIjpcIuaAu+aUtui0uVwiLFwiZGVzY1wiOm51bGwsXCJmZWVcIjoxOTQuMH1dfSIsIui/meS4quWSjDpkYXRlOjIwMjAtMTEtMjciOiJ7XCJkYXRlXCI6XCIyMDIwLTExLTI3IDEyOjAwOjAwLjAwMFpcIixcImVsZWN0XCI6MTAsXCJ3YXRlclwiOjMwfSIsImhlcm1lczpmbG9vcjor55qEIjoiW3tcIm5hbWVcIjpcIm5cIixcInNvcnRcIjo5OX1dIn0=



//H4sIAEy0GmAA/9WUz2vUQBTH/5UwR90NbybJlgx4EKmn3tqTRsraTmkhP0oS8VAWBJVVsQdtFbQHRXAFEfRQRV3Ff2azXf8L30y22fzYHSt6cQm7m/fe9/smeZ+ZPTL58Wz0+W32+CGPdtOdKORbQhBOru55JOwGwiPcI+PX38av3k+Ov3ik5REswKhtQu8aaZFtEQci4Vt+FMX8PK1LT57fyQ762cFASZMoTjHsulNpIOKpNKkLaU3QKieZNjn76Mqs35d0dcnruuTo+8tscE9XkT15oE0fHeFbL1dAtQBfrE6fv/f8W1c32b8/Gj4dDd8VgjmDKhhZX7m4ura+uryyfGkNB8aAQZuyNjjloilB2CUWoXSxwAT0FL7YSC8reKgK3OymIs4DDGmqeGxijpf8lZ8M5iMuEgal3HHwMjtAqZ2PU3WSyy+6yJ5QaxFHUSDXypOwu5tsR+msH1vUr+S/+Ela9SdPo7Try/XY6nYnFUGCt9WNcvjxdINtimRDxRww2gYF44Jhg5F9HXheiH/OGdhUxfAnu3u7vCkxVJ3v+MNxw9aWtpa0QO9sv4+2VNoyZcvOYnvy5sXP/qOybXjD9wuB1VxH5QiZp7EbklvD8eEnncRVh1CvcQrlm6d+ohST1xFeA28xCAa1OO1wsEy2ZDsurYDnlMGzz87dYs7/ijv6p+C5khDnn4OHWxB9benROSWvMyOP/kfo0Rl7c9mhbbY0d5gygU/KAfAyAeBKhRxaJseCJtt4QtfBDhtA934BcLWHv9gHAAA=