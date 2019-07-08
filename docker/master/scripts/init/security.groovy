import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.oktaauth.OktaAuthentication

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)

SecurityRealm realm = new OktaAuthentication("https://coxauto.okta.com")

Jenkins.instance.setSecurityRealm(realm)
Jenkins.instance.setAuthorizationStrategy(strategy)

Jenkins.instance.save()
