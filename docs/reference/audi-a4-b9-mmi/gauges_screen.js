

angular.module('gaugesScreen', [])
.controller('GaugesScreenController', function($scope, $window) {
  var units = {uiUnitConsumptionRate: "metric",
  uiUnitDate: "ger",
  uiUnitEnergy: "metric",
  uiUnitLength: "metric",
  uiUnitPower: "hp",
  uiUnitPressure: "bar",
  uiUnitTemperature: "c",
  uiUnitTorque: "metric",
  uiUnitVolume: "l",
  uiUnitWeight: "kg"};

  $scope.data = {}
  // overwriting plain javascript function so we can access from within the controller
  $window.setup = (setupData) => {
    for(let dk in setupData){
      if(typeof dk == "string" && dk.startsWith("uiUnit")){
        units[dk] = setupData[dk];
      }
    }
    vueEventBus.emit('SettingsChanged', {values:units})

    $scope.data.speedUnit = units.uiUnitLength=="metric"?"km/h":"mph";

    if(units.uiUnitConsumptionRate == "metric"){
      $scope.data.consumptionUnit = "l/100km"
    }else{
      $scope.data.consumptionUnit = "mpg"
      document.getElementById('markOne').textContent = "30";
      document.getElementById('markTwo').textContent = "20";
      document.getElementById('markThree').textContent = "10";
      document.getElementById('markFour').textContent = "0";
    }
  }

  $window.updateData = (data) => {
    $scope.$evalAsync(function() {
      // We need access to the efficiency bar svg element so that we can animate it
      var eff = document.getElementById("efficiency");

      if(!eff){return;} //html not ready yet

      value = data.customModules.combustionEngineData.fuelDisplay;
      // dash array needs to be the same as the circumference of the circle (radius * 2 * PI)
      eff.style.strokeDasharray = 342

      if (value > 0) {
        // We need to add the value to the negative circumference of the circle so that we can fill up the bar
        eff.style.strokeDashoffset = -342 + value.toFixed(2) * 23
        eff.style.stroke = "#BD362F";
      }
      else {
        eff.style.strokeDashoffset = -342 + value.toFixed(2) * 23
        eff.style.stroke = "#295AAC";
      }

      if (data.electrics.gear === -1) {
        $scope.data.gear = "R";
      }
      else if (data.electrics.gear === 0) {
        $scope.data.gear = "N";
      }
      else {
        $scope.data.gear = data.electrics.gear;
      }

      $scope.data.time = data.customModules.environmentData.time;

      $scope.data.speedVal = UiUnits.speed(data.electrics.wheelspeed).val.toFixed(0);
      let tempEnv = UiUnits.temperature(data.customModules.environmentData.temperatureEnv)
      if (tempEnv.val.toFixed(1) > 99.9 || tempEnv.val.toFixed(1) < -99.9) {
        $scope.data.temp = "---°C";
      }else {
        $scope.data.temp = tempEnv.val.toFixed(1) + tempEnv.unit;
      }

      let conso = UiUnits.consumptionRate(data.customModules.combustionEngineData.averageFuelConsumption*1e-5)
      if(conso.val === "n/a")
        $scope.data.consumptionVal = "---"
      else
        $scope.data.consumptionVal = conso.val.toFixed(1)

      if(data.electrics.odometer){
        let val = data.electrics.odometer
        val *= (units.uiUnitLength=="metric")?0.001:0.0006215;
        val = Math.min(999999,val);
        $scope.data.odo=  val.toFixed(0)+((units.uiUnitLength=="metric")?"km":"mi")
      }else{$scope.data.odo=""}
    })
  }

  elgorilla.sendActiveObjectLua('controller.getControllerSafe("etkGauges").uiReady()');
});