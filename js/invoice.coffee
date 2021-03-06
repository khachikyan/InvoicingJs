class Item
	constructor: (@qty, @description, @unit_price, @css, @id) ->
		@amount = parseFloat(this.round(@qty * @unit_price))

	round: (amount) ->
		amount.toFixed(2)

	amount: ->
		@amount = parseFloat(this.round(@qty * @unit_price))

class Client
	constructor: (@name, @address, @city_state_zip, @phone) ->

class Company
	constructor: (@name, @address, @phone) ->


client = JSON.parse(localStorage.getItem('invoiceClient')) || new Client("Coyote", "1 Road Runner rd.", "Address Line 2", "416-123-4567")
company = JSON.parse(localStorage.getItem('invoiceCompany')) || new Company("Company Name", "Company Address line 1\nCompany Address Line 2\nCity, State, Zip", "416-000-0000")


window.Invoice = angular.module('Invoice', [])

window.Invoice.controller 'InvoiceCtrl', ($scope) ->


	# $scope.itemsObject = {}
	# $scope.itemsObject.items = []

	$scope.items = JSON.parse(localStorage.getItem('invoiceItems')) || [new Item(1, "Acme Bird Seed", 13.25, '', 0)]
	$scope.autoincrement = parseInt(localStorage.getItem('autoincrement'))
	$scope.company = company
	$scope.client = client
	$scope.date = new Date().toLocaleDateString()
	$scope.number = (Math.random()*100).toFixed(0)
	$scope.freight = 0
	$scope.fields = JSON.parse(localStorage.getItem('invoiceFields')) || []
	

	$scope.addField = ->
		$scope.fields.push ({name: '', value: '',  symbol: '', css:'dontPrint'})

	$scope.addItem = ->
		item = new Item('','','','dontPrint')
		item.id = $scope.autoincrement
		$scope.items.push(item)
		$scope.itemsObject.items.push item
		++$scope.autoincrement
		localStorage.autoincrement = $scope.autoincrement

	$scope.removeItem = (item) ->		
		i = $scope.items.indexOf(item)
		if i != -1
			$scope.items.splice(i,1)


	$scope.removeField = (field) ->		
		i = $scope.fields.indexOf(field)
		console.log i
		if i != -1
			$scope.fields.splice(i,1)

	$scope.updateSubtotal = ->
		sum = 0
		for item in $scope.items
			if item.qty == '0' || item.qty == ''
				item.css = 'dontPrint'
			else item.css = ''
			sum += parseFloat(item.qty * item.unit_price)
		return sum

	$scope.subtotal = $scope.updateSubtotal()

	$scope.$watch 'items', ->
		$scope.subtotal = $scope.updateSubtotal()
		$scope.total = $scope.updateTotal()
		localStorage.invoiceItems = JSON.stringify($scope.items)
	, true

	$scope.$watch 'fields', ->
		$scope.total = $scope.updateTotal()
		localStorage.invoiceFields = JSON.stringify($scope.fields)
	, true

	$scope.$watch 'company', ->
		localStorage.invoiceCompany = JSON.stringify($scope.company)
	, true

	$scope.$watch 'client', ->
		localStorage.invoiceClient = JSON.stringify($scope.client)
	, true

	$scope.parseFields = ->
		for field in $scope.fields
			v = field.value		
			
			if v == ''
				field.css = 'dontPrint'
			else field.css = ''

			if v[0] == "$" || v[0] == '€' || v[0] == '£'
				field.symbol = 'currency'
			else if v[v.length-1] == "%"
				field.symbol = '%'
			else
				field.symbol = ''

	$scope.updateTotal = ->
		t = $scope.subtotal
		$scope.parseFields()
		for field in $scope.fields
			if field.value != ''
				if field.symbol == '%'
					t += (t * parseFloat(parseFloat(field.value))/100)
				else if field.symbol == 'currency'
					t += parseFloat(field.value.substring(1))
				else
					t += parseFloat(field.value)
		return t

	$scope.total = $scope.updateTotal()

	return
