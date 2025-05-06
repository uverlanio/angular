import { Component, computed, effect, signal } from '@angular/core';

@Component({
  selector: 'app-signals',
  standalone: true,
  imports: [],
  templateUrl: './signals.component.html',
  styleUrl: './signals.component.scss'
})
export class SignalsComponent {

  public firstName = signal('Uver ');
  public lastName = signal('Mauricio');

  public fullName = computed( ()=> {
    return this.firstName() + this.lastName();
  }
  );

  public array = signal([1]);

  constructor(){
    effect( () => {
      console.log(this.firstName);
      console.log(this.array);
    })
  }

  public updateName(){
    return this.firstName.set("João ")
  }

  public updateArray(){
    this.array.update( (oldValue: Array<number>) => {
      console.log(oldValue);
      return [...oldValue, oldValue.length + 1];
    }) 
  }

}
