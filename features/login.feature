Feature: login
  
  Scenario: UserName does not exsist (General Manager)
    Given I am on the login page
    When I fill in "username" with "general-manager"
    When I fill in "password" with "nonsense"
    When I press "log in" within "form"
    Then I should see "We don't seem to have a user with that username."
  
  Scenario: Wrong password entered (General Manager)
    Given I am on the login page
    When I fill in "username" with "general-manager-sheffield"
    When I fill in "password" with "nonsense"
    When I press "log in" within "form"
    Then I should see "Incorrect password."

  Scenario: Correct password entered (General Manager)
    Given I am on the login page
    When I fill in "username" with "general-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: general-manager-sheffield"
    
  Scenario: Correct password entered (General Manager)
    Given I am on the login page
    When I fill in "username" with "general-manager-manchester"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: general-manager-manchester"

  Scenario: Correct password entered (Market Manager)
    Given I am on the login page
    When I fill in "username" with "marketting-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: marketting-manager-sheffield"
  
  Scenario: Correct password entered (Market Manager)
    Given I am on the login page
    When I fill in "username" with "marketting-manager-manchester"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: marketting-manager-manchester"
    
  
  Scenario: Correct password entered (Car Manager)
    Given I am on the login page
    When I fill in "username" with "car-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: car-manager-sheffield"
   
  Scenario: Correct password entered (Car Manager)
    Given I am on the login page
    When I fill in "username" with "car-manager-manchester"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: car-manager-manchester"

  
  Scenario: Correct password entered (Twitter Manager)
    Given I am on the login page
    When I fill in "username" with "twitter-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: twitter-manager-sheffield"
  
  Scenario: Correct password entered (Twitter Manager)
    Given I am on the login page
    When I fill in "username" with "twitter-manager-manchester"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: twitter-manager-manchester"
  
  Scenario: Correct password entered (Account Manager)
    Given I am on the login page
    When I fill in "username" with "accounts-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: accounts-manager-sheffield"
 
 Scenario: Correct password entered (Account Manager)
    Given I am on the login page
    When I fill in "username" with "accounts-manager-manchester"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: accounts-manager-manchester"
    
 Scenario: Correct password entered (Customer Page)
    Given I am on the login page
    When I fill in "username" with "todd"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: todd"
