Feature: Sending Retweet Competition

  Scenario: Correct password entered
    Given I am on the login page
    When I fill in "username" with "marketting-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to marketmanager page
    Then I should see "Market Manager Dashboard"
    Then I go to the account page
    Then I should see "You're logged in as: marketting-manager-sheffield"
    Then I should see "Your account is of type: marketting_manager"