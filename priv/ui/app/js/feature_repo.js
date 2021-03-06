var jquery = require('jquery');
var FeatureModel = require("./feature_model");

var FeatureRepo = function(url){
  this.url = url;
};

FeatureRepo.prototype.fetchFeatures = function(onSuccess, onError){
  var featureModelBuilder = function(featureData){
    var featureModelData = featureData.map(function(feature){
      return new FeatureModel(feature);
    });
    onSuccess(featureModelData);
  };

  jquery.ajax({
    url: this.url,
    dataType: 'json',
    success: featureModelBuilder,
    error: onError || function(xhr, status, err) {
      console.error(status, err);
    }
  });
};

FeatureRepo.prototype.createFeature = function(feature, onSuccess, onError){
  jquery.ajax({
    url: this.url,
    contentType: 'application/json',
    type: 'POST',
    data: JSON.stringify(feature),
    success: onSuccess,
    error: onError || function(xhr, status, err) {
      console.error(status, err);
    }
  });
}

FeatureRepo.prototype.updateFeature = function(feature, onSuccess, onError){
  jquery.ajax({
    url: this.url + "/" + feature.id,
    contentType: 'application/json',
    type: 'PUT',
    data: JSON.stringify(feature),
    success: onSuccess,
    error: onError || function(xhr, status, err) {
      console.error(status, err);
    }
  });
}

FeatureRepo.prototype.deleteFeature = function(feature, onSuccess, onError){
  jquery.ajax({
    url: this.url + "/" + feature.id,
    type: 'DELETE',
    success: onSuccess,
    error: onError || function(xhr, status, err) {
      console.error(status, err);
    }
  })
}

module.exports = FeatureRepo;
