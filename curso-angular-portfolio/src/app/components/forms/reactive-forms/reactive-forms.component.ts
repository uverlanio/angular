import { CommonModule } from '@angular/common';
import { Component, inject, OnInit } from '@angular/core';
import { AbstractControl, FormArray, FormBuilder, FormControl, FormGroup, ReactiveFormsModule, ValidatorFn, Validators } from '@angular/forms';

function textValidator(): ValidatorFn{
  return (control: AbstractControl) => {
    const hasUpperCase = /[A-Z]/.test(control.value)
    const hasNumber = /[[0-9]/.test(control.value)
    if(hasUpperCase && hasNumber){
      return null;
    }
    return { textValidator: true };
  }
}
@Component({
  selector: 'app-reactive-forms',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './reactive-forms.component.html',
  styleUrl: './reactive-forms.component.scss'
})
export class ReactiveFormsComponent {
  #fb = inject(FormBuilder);

  public profileForm = this.#fb.group({
    name: ['', [Validators.required, textValidator()]],
    myStacks: this.#fb.group({
      front: ['Angular'],
      back: ['Java']
    }),
    myFavouriteFoods: this.#fb.array([['X-tudo']])
  })

  public update(){
    this.profileForm.patchValue({
      name: 'Maria',
      myStacks: {
        front: 'Vue',
        back: 'NodeJS'
      }
    })
  }

  public addMyFavouriteFoods(newFood: string){
    const myFavouriteFood = this.profileForm.get('myFavouriteFoods') as FormArray;
    const addNewFood = this.#fb.control(newFood);

    myFavouriteFood.push(addNewFood);
  }

  public submit(){
    console.log(this.profileForm.valid)
    if(this.profileForm.valid)
      console.log(this.profileForm.value)
  }
}
