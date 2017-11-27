angular.module('loomioApp').directive 'documentUploadForm', (Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/document/upload_form/document_upload_form.html'
  replace: true
  controller: ($scope, $element) ->

    $scope.$watch 'files', ->
      $scope.upload($scope.files)

    $scope.upload = ->
      return unless $scope.files
      $scope.model.setErrors({})
      $scope.$emit 'processing'
      for file in $scope.files
        $scope.currentUpload = Records.attachments.upload(file, $scope.progress)
        $scope.currentUpload.then($scope.success, $scope.failure).finally($scope.reset)

    $scope.selectFile = ->
      $element.find('input')[0].click()

    $scope.progress = (progress) ->
      $scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)

    $scope.abort = ->
      $scope.currentUpload.abort() if $scope.currentUpload

    $scope.success = (response) ->
      data = response.data || response
      _.each data.attachments, (attachment) ->
        $scope.$emit 'fileUploaded', attachment

    $scope.failure = (response) ->
      $scope.model.setErrors(response.data.errors)

    $scope.reset = ->
      $scope.$emit 'doneProcessing'
      $scope.files = $scope.currentUpload = null
      $scope.percentComplete = 0
    $scope.reset()

    $scope.$on 'filePasted', (event, file) ->
      $scope.files = [file]
