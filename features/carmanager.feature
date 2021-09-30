Feature: carmanager_DashBoard_View_Car
  Scenario: Correct password entered (Car Manager)
    Given I am on the login page
    When I fill in "username" with "car-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: car-manager-sheffield"
    Then I go to the carmanager page
    Then I should see "Car Manager Dashboard"
    Then I should see "Taxi Number"
    Then I should see "Type of Vehicle"
    Then I should see "Available"
    
    

