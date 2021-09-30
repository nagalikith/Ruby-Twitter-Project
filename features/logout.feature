Feature: logout
    Scenario: Successful Login and Log out (General Manager)
        Given I am on the login page
        When I fill in "username" with "general-manager-manchester"
        When I fill in "password" with "Password2!"
        When I press "log in" within "form"
        Then I go to the account page
        Then I should see "You're logged in as: general-manager-manchester"
        Then I should see "Log Out"