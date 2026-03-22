import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:hermes/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';

import 'RoomBill.dart';

class RoomReading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RoomReadingState();
  }
}

class RoomReadingState extends HermesState<RoomReading> {
  // Date picker state
  bool _isStartDateSelected = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _tempSelectedDay;

  //edit previous reading state
  bool _editPreviousReading = false;

  @override
  Widget build(BuildContext context) {
    var model = (ModalRoute.of(context)!.settings.arguments as RoomModel);

    return ChangeNotifierProvider.value(
      value: model,
      child: Consumer<RoomModel>(
        builder: (ctx, model, child) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                '${model.title??""} • 录入抄表读数',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 01: Date Selector
                  _buildDateSelector(model),
                  SizedBox(height: 32),

                  // Step 02: Meter Readings
                  _buildMeterReadings(model),
                  SizedBox(height: 32),

                  // Generate Bill Button
                  _buildGenerateBillButton(model),
                  SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(RoomModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '时间范围',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Period Range',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showDatePicker(model, isStartDate: true),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: !_isStartDateSelected ? null : Border.all(
                      color: AppColors.secondary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '起始日期',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: !_isStartDateSelected ? AppColors.onSurfaceVariant : AppColors.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        Util.formatDay(model.subBlock.selectedDay),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _showDatePicker(model, isStartDate: false),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: _isStartDateSelected ? null : Border.all(
                      color: AppColors.secondary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '结束日期',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: _isStartDateSelected ? AppColors.onSurfaceVariant : AppColors.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        Util.formatDay(model.mainBlock.selectedDay),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDatePicker(RoomModel model, {required bool isStartDate}) {
    setState(() {
      _isStartDateSelected = isStartDate;
      _focusedDay = isStartDate ? model.subBlock.selectedDay : model.mainBlock.selectedDay;
      _tempSelectedDay = _focusedDay;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildCalendarBottomSheet(isStartDate?model.subBlock:model.mainBlock, setModalState);
        },
      ),
    );
  }

  Widget _buildCalendarBottomSheet(MarkerBlock block, StateSetter setModalState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择账期',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async{
                      if (_tempSelectedDay != null) {
                        await block.loadDay(_tempSelectedDay!);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Text(
                      '确定',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Calendar
          TableCalendar(
            locale: 'zh_CN',
            firstDay: DateTime.utc(1976, 9, 9),
            lastDay: DateTime.utc(2099, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return _tempSelectedDay != null &&
                  Util.isSameDay(_tempSelectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setModalState(() {
                _tempSelectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              block.loadEvents(focusedDay);
            },
            eventLoader: (day) {
              bool marked = block.roomModel?.isDayMarked(day)??false;
              return marked?[1]:[];
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) {
                return '${date.year}年 ${date.month}月';
              },
              titleTextStyle: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.onSurfaceVariant),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              outsideTextStyle: TextStyle(
                color: AppColors.outlineVariant.withOpacity(0.4),
              ),
              defaultTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              weekendTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimaryFixed,
              ),
              rangeHighlightColor: AppColors.primaryFixed.withOpacity(0.5),
              withinRangeTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              rangeStartDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMeterReadings(RoomModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 02 / 02',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary.withOpacity(0.5),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '读数录入',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Electricity & Water',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: AppColors.onPrimaryFixed,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Electricity Section
        _buildElectricitySection(model),
        SizedBox(height: 16),

        // Water Section
        _buildWaterSection(model),
      ],
    );
  }

  Widget _buildElectricitySection(RoomModel model) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFFA1F4C8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt, color: Color(0xFF1B724F), size: 24),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '电表录入',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '共 ${model.electMeters} 个',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (int i = 1; i <= model.electMeters; i++)
                    _buildElectricMeterCard(model, i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeterCard({
    required TextEditingController previousReadingController,
    required TextEditingController currentReadingController,
    required String title,
    required double price,
    required double previousReading,
    required double currentReading,
    required double usage,
    required double fee,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(color: AppColors.secondary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '单价: $price 元/度',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: currentReading == 0? AppColors.surfaceContainerHigh : usage >= 0 ? AppColors.primaryFixed : Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentReading == 0? '待录入' : usage >= 0 ? '用量正常' : '用量异常',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: currentReading == 0? AppColors.onSurfaceVariant : usage >= 0 ? AppColors.onPrimaryFixed : Color(0xFFBA1A1A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _editPreviousReading?null:AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '上次读数',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                      ),
                      // SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 2,
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: previousReadingController,
                          enabled: _editPreviousReading,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\.0-9\-+]')),
                          ],
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: AppColors.outlineVariant,
                            ),
                            contentPadding: EdgeInsets.only(bottom: 5),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '本次读数',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: AppColors.secondary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 2,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: currentReadingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\.0-9\-+]')),
                        ],
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppColors.outlineVariant,
                          ),
                          contentPadding: EdgeInsets.only(bottom: 5),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.surfaceContainerLow,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '本次用量',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: usage.toStringAsFixed(2),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' 度',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '预估费用',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '¥${fee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricMeterCard(RoomModel model, int seq) {
    var subController = model.subBlock.meterController(seq);
    var mainController = model.mainBlock.meterController(seq);
    double price = model.room?.room.electFee ?? 0;
    double previousReading = model.subBlock.elect(seq);
    double currentReading = model.mainBlock.elect(seq);
    double usage = currentReading - previousReading;
    double fee = usage * price;
    return _buildMeterCard(
        previousReadingController: subController.electController,
        currentReadingController: mainController.electController,
        title: '电表 ${seq.toString().padLeft(2, '0')}',
        price: price,
        previousReading: previousReading,
        currentReading: currentReading,
        usage: usage,
        fee: fee
    );
  }

  Widget _buildWaterSection(RoomModel model) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.onPrimaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.water_drop, color: AppColors.onPrimaryContainer, size: 24),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '水表录入',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '共 ${model.waterMeters} 个',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (int i = 1; i <= model.waterMeters; i++)
                    _buildWaterMeterCard(model, i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterMeterCard(RoomModel model, int seq) {
    var subController = model.subBlock.meterController(seq);
    var mainController = model.mainBlock.meterController(seq);
    double price = model.room?.room.waterFee ?? 0;
    double previousReading = model.subBlock.water(seq);
    double currentReading = model.mainBlock.water(seq);
    double usage = currentReading - previousReading;
    double fee = usage * price;

    return _buildMeterCard(
        previousReadingController: subController.waterController,
        currentReadingController: mainController.waterController,
        title: '水表 ${seq.toString().padLeft(2, '0')}',
        price: price,
        previousReading: previousReading,
        currentReading: currentReading,
        usage: usage,
        fee: fee
    );

  }

  Widget _buildGenerateBillButton(RoomModel model) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Row(
                  children: [
                    Text(
                      '编辑上次读数',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _editPreviousReading ? AppColors.secondary : AppColors.onSurfaceVariant,
                      ),
                    ),
                    Switch(
                      value: _editPreviousReading,
                      onChanged: (value) {
                        setState(() {
                          _editPreviousReading = value;
                        });
                      },
                      activeColor: AppColors.secondary,
                      activeTrackColor: AppColors.primaryFixed,
                    ),

                  ],
                ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await model.subBlock.submit();
                  await model.mainBlock.submit();
                  Toast.show("保存成功!");
                },
                icon: Icon(Icons.save_outlined, color: AppColors.secondary, size: 18),
                label: Text(
                  '仅保存',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.secondary, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await model.subBlock.submit();
              await model.mainBlock.submit();

              var id = model.id;
              var fee = model.calculateResult();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => RoomBill(),
                  settings: RouteSettings(arguments: {"roomId": id, "feeResult": fee}),
                ),
              );

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  transform: GradientRotation(135 * 3.14159 / 180),
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '生成账单明细',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.receipt_long, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}