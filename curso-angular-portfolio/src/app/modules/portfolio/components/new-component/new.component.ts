import { Component, OnInit } from '@angular/core';
import { ApiService } from 'app/services/api.service';

@Component({
  selector: 'app-new-component',
  standalone: true,
  imports: [],
  templateUrl: './new.component.html',
  styleUrl: './new.component.scss'
})
export class NewComponent implements OnInit{

  public name = 'New Component';

  constructor(private _apiService: ApiService){}

  ngOnInit(): void {
    console.log(this._apiService.name());

    this._apiService.name$.subscribe({
      next: (next) => console.log(next),
      error: (error) => console.log(error),
      complete: () => console.log('Complete!'),
    
    });

    this._apiService.name$.next('Uver $$');
  }

}
