import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-template-driven-forms',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './template-driven-forms.component.html',
  styleUrl: './template-driven-forms.component.scss'
})
export class TemplateDrivenFormsComponent {

}
