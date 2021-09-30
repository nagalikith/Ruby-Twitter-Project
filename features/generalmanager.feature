Feature: Access_to_all_accounts
  Scenario: Correct password entered (General Manager)
    Given I am on the login page
    When I fill in "username" with "general-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: general-manager-sheffield"
    Then I go to the carmanager page
    Then I should see "Car Manager Dashboard"
    Then I go to twittermanager page
    Then I should see "Please select a conversation on the left"
    Then I go to marketmanager page
    Then I should see "Market Manager Dashboard"
    Then I go to the previousride page
    Then I should see "Previous Rides"
    Then I go to the accountsmanager page
    Then I should see "User Data"