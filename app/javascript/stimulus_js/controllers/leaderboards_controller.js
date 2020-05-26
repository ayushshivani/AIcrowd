import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['participantCountry', 'participantAffiliation']

  filterURL(event){
    event.preventDefault();

    let url = window.location.origin + window.location.pathname

    let params = ''
    let country = this.participantCountryTarget.selectedOptions[0].innerText
    let countryPresent = country !== '' && country !== 'select-country'

    let affiliation = this.participantAffiliationTarget.selectedOptions[0].innerText
    let affiliationPresent = affiliation !== '' && affiliation !== 'select-affiliation'

    if(affiliationPresent){
      if(countryPresent){
        params = params.concat('country_name=', country).concat('&affiliation=', affiliation);
      }else{
        params = params.concat('affiliation=', affiliation);
      }
    }else if(countryPresent){
      params = params.concat('country_name=', country);
    }

    if(countryPresent || affiliationPresent){
      window.location.href = url.concat('?').concat(params);
    }else{
      window.location.href = url
    }
  }
}
