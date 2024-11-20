//
//  ContentView.swift
//  EPSSem14
//
//  Created by Joseph Flores on 20/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var grossSalary: String = ""
        @State private var isAFP: Bool = true
        @State private var epsCost: String = ""
        @State private var includeEPS: Bool = false
        @State private var bonuses: String = ""
        
        @State private var netSalary: Double = 0.0
        @State private var totalDeductions: Double = 0.0
        @State private var pensionDeduction: Double = 0.0
        @State private var incomeTax: Double = 0.0
        @State private var epsDeduction: Double = 0.0
        
        let UIT = 4950.0 // Valor UIT en 2024
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Datos del Trabajador")) {
                        TextField("Sueldo Bruto Mensual (S/)", text: $grossSalary)
                            .keyboardType(.decimalPad)
                        
                        Picker("Aporte Previsional", selection: $isAFP) {
                            Text("AFP").tag(true)
                            Text("ONP").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Toggle("¿Tiene EPS?", isOn: $includeEPS)
                        
                        if includeEPS {
                            TextField("Costo EPS (S/)", text: $epsCost)
                                .keyboardType(.decimalPad)
                        }
                        
                        TextField("Bonos / Ingresos Adicionales (S/)", text: $bonuses)
                            .keyboardType(.decimalPad)
                    }
                    
                    Section {
                        Button("Calcular") {
                            calculatePayroll()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Section(header: Text("Desglose de Boleta")) {
                        Text("Sueldo Bruto: S/ \(grossSalary.isEmpty ? "0.00" : grossSalary)")
                        Text("Total Descuentos: S/ \(totalDeductions, specifier: "%.2f")")
                        Text("Sueldo Neto: S/ \(netSalary, specifier: "%.2f")")
                    }
                    
                    Section(header: Text("Detalles de Descuentos")) {
                        Text("Aporte Previsional: S/ \(pensionDeduction, specifier: "%.2f")")
                        Text("Impuesto a la Renta: S/ \(incomeTax, specifier: "%.2f")")
                        if includeEPS {
                            Text("Descuento EPS: S/ \(epsDeduction, specifier: "%.2f")")
                        }
                    }
                }
                .navigationTitle("Boleta de Pago")
            }
        }
        
        func calculatePayroll() {
            guard let grossSalaryDouble = Double(grossSalary),
                  let bonusesDouble = Double(bonuses.isEmpty ? "0" : bonuses) else {
                return
            }
            
            let totalIncome = grossSalaryDouble + bonusesDouble
            
            // Cálculo de Aporte Previsional
            if isAFP {
                pensionDeduction = totalIncome * 0.10
            } else {
                pensionDeduction = totalIncome * 0.13
            }
            
            // Cálculo de Impuesto a la Renta
            let annualSalary = totalIncome * 12
            let taxableBase = max(0, annualSalary - (UIT * 7))
            
            incomeTax = calculateIncomeTax(base: taxableBase) / 12
            
            // Cálculo EPS
            if includeEPS, let epsCostDouble = Double(epsCost) {
                let essaludContribution = grossSalaryDouble * 0.0675
                epsDeduction = max(0, epsCostDouble - essaludContribution)
            } else {
                epsDeduction = 0
            }
            
            // Total de Descuentos y Sueldo Neto
            totalDeductions = pensionDeduction + incomeTax + epsDeduction
            netSalary = totalIncome - totalDeductions
        }
        
        func calculateIncomeTax(base: Double) -> Double {
            var tax = 0.0
            var remainingBase = base
            
            // Hasta 5 UIT (8%)
            let firstBracket = min(remainingBase, UIT * 5)
            tax += firstBracket * 0.08
            remainingBase -= firstBracket
            
            // Más de 5 UIT hasta 20 UIT (14%)
            let secondBracket = min(remainingBase, UIT * 15)
            tax += secondBracket * 0.14
            remainingBase -= secondBracket
            
            // Más de 20 UIT hasta 35 UIT (17%)
            let thirdBracket = min(remainingBase, UIT * 15)
            tax += thirdBracket * 0.17
            remainingBase -= thirdBracket
            
            // Más de 35 UIT hasta 45 UIT (20%)
            let fourthBracket = min(remainingBase, UIT * 10)
            tax += fourthBracket * 0.20
            remainingBase -= fourthBracket
            
            // Más de 45 UIT (30%)
            tax += remainingBase * 0.30
            
            return tax
        }
}

#Preview {
    ContentView()
}
