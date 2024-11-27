import SwiftUI

struct LaunchView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        if isActive {
            ContentView() // Ana içeriğe geçiş
        } else {
            ZStack {
                Color(red: 255/255, green: 201/255, blue: 27/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image(systemName: "checklist") // Sistem ikonu
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                    
                    Text("Görev Listesi")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("To Do List")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(scaleEffect)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        self.scaleEffect = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                // 2 saniye sonra ana içeriğe geç
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
