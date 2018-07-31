import { Component, Inject } from '@angular/core';
import { Http } from '@angular/http';
import { AppConfiguration } from '../../app.configuration';
import { User } from '../../core/models/user.model';

@Component({
    selector: 'fetchdata',
    templateUrl: './fetchdata.component.html'
})
export class FetchDataComponent {
    public Users: User[];
    //baseUrl + 'api/SampleData/WeatherForecasts'
    constructor(http: Http,  private appConfig: AppConfiguration) //,@Inject('BASE_URL') baseUrl: string,
    {
        //http.get('http://localhost/FxWin.WebApp/api/Users')
        //    .subscribe(result => {
        //        this.Users = result.json() as User[];
        //    }, error => console.error(error));
        console.debug();
        if (appConfig != null && appConfig.getConfig('webApi') !== 'undefined') {
            http.get(appConfig.getConfig('webApi').dbWebApiUrl + '/Users')
                .subscribe(result => {
                    this.Users = result.json() as User[];
                }, error => console.error(error));
        }
      
    }
}


