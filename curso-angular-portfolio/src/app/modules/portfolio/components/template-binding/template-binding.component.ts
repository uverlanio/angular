import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-template-binding',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './template-binding.component.html',
  styleUrl: './template-binding.component.scss'
})
export class TemplateBindingComponent {
  public name = 'Uver';
  public age = 30;
  public condition = this.age;
  public isDisabled = true;
  public srcValue = '';
  public isTextDecoration = this.age >= 32 ? 'underline' : 'none';

  public sum(){
    return this.age++;
  }

  public sub(){
    return this.age--;
  }

  public onKeyDown(event: Event){
    return console.log(event)
  }

  public onMouseMove(event: MouseEvent){
    return console.log({
      clientX: event.clientX,
      clientY: event.clientY
    })
  }

}
