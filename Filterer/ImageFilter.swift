import Foundation

public struct Filters {
    

    
    public static func  increaseBrightnessFilter(imageRGBA image:RGBAImage ,Percentage percentage:Double , completionBlock:@escaping (RGBAImage?)->Void) {
        let resultImage:RGBAImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
                let index = y * resultImage.width + x
                var pixel = resultImage.pixels[index]
                pixel.red    = UInt8(max(0, min(255, Double(pixel.red) * ( 1 + percentage / 100) )))
                pixel.green  = UInt8(max(0, min(255, Double(pixel.green) * ( 1 + percentage / 100) )))
                pixel.blue   = UInt8(max(0, min(255, Double(pixel.blue) * ( 1 + percentage / 100) )))
                resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    public static func  decreaseBrightnessFilter(imageRGBA image:RGBAImage ,Percentage percentage:Double, completionBlock:@escaping (RGBAImage?)->Void) {
        let resultImage:RGBAImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
                let index = y * resultImage.width + x
                var pixel = resultImage.pixels[index]
                pixel.red    = UInt8(max(0, min(255, Double(pixel.red) * ( 1 - percentage / 100) )))
                pixel.green  = UInt8(max(0, min(255, Double(pixel.green) * ( 1 - percentage / 100) )))
                pixel.blue   = UInt8(max(0, min(255, Double(pixel.blue) * ( 1 - percentage / 100) )))
                resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    // arbitrary threshold to determine that a pixel can be counted as dark/light is usually 127.
    // subtract this from pixel RGB value to apply contrast. and subtracted value should be within bounds [0,255]
    
    public static func  contrastFilter(imageRGBA image:RGBAImage ,Percentage percentage:Double, completionBlock:@escaping (RGBAImage?)->Void) {
        let resultImage:RGBAImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
               let index = y * resultImage.width + x
               var pixel = resultImage.pixels[index]
               pixel.red    = UInt8(max(0, min(255,Double(pixel.red) * ( 1 + percentage / 100) - 127)))
               pixel.green  = UInt8(max(0, min(255,Double(pixel.green) * ( 1 + percentage / 100) - 127)))
               pixel.blue  = UInt8(max(0, min(255,Double(pixel.blue) * ( 1 + percentage / 100) - 127)))
               resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    public static func  blackAndWhiteFilter(imageRGBA image:RGBAImage ,Percentage percentage:Double, completionBlock:@escaping (RGBAImage?)->Void) {
        let resultImage:RGBAImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
                let index = y * resultImage.width + x
                var pixel = resultImage.pixels[index]
                let gray = max(0, min(255,((Double(pixel.red) + Double(pixel.green) + Double(pixel.blue))/3) * ( 1 + percentage / 100) ))
                pixel.red    = UInt8(gray)
                pixel.green  = UInt8(gray)
                pixel.blue   = UInt8(gray)
                resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    public static func negativeFilter(imageRGBA image:RGBAImage, completionBlock:@escaping (RGBAImage?)->Void) {
        let resultImage:RGBAImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
                let index = y * resultImage.width + x
                var pixel = resultImage.pixels[index]
                pixel.red    = UInt8(255 - (Double(pixel.red)))
                pixel.green  = UInt8(255 - (Double(pixel.green)))
                pixel.blue   = UInt8(255 - (Double(pixel.blue)))
                resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    public static func grayScaleFilter(imageRGBA image:RGBAImage, completionBlock:@escaping (RGBAImage?)->Void) {
        let resultImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
                let index = y*resultImage.width + x
                var pixel = resultImage.pixels[index]
                let gray = max(0, min(255,((Double(pixel.red) + Double(pixel.green) + Double(pixel.blue))/3)))
                pixel.red    = UInt8(gray)
                pixel.green  = UInt8(gray)
                pixel.blue   = UInt8(gray)
                resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    public static func getRGBFilteredImage(red:UInt8,green:UInt8,blue:UInt8,image:RGBAImage, completionBlock:@escaping (RGBAImage?)->Void){
        let resultImage = image
        for y in 0..<resultImage.height{
            for x in 0..<resultImage.width{
                let index = y*resultImage.width + x
                var pixel = resultImage.pixels[index]
                if red == 0{
                    pixel.red = red
                }
                if green == 0{
                    pixel.green = green
                }
                if blue == 0{
                    pixel.blue = blue
                }
                resultImage.pixels[index] = pixel
            }
        }
        completionBlock(resultImage)
    }
    
    public static func applyDefaultFilters(image:RGBAImage ,name :String, completionBlock:@escaping (RGBAImage?)->Void) {
        switch name {
            case "Brightness" :
                increaseBrightnessFilter(imageRGBA: image, Percentage: 50, completionBlock: completionBlock)
            case "Contrast" :
                contrastFilter(imageRGBA: image, Percentage: 70, completionBlock: completionBlock)
            case "BlackAndWhite" :
                blackAndWhiteFilter(imageRGBA: image, Percentage: 20, completionBlock: completionBlock)
            case "Negative" :
                negativeFilter(imageRGBA: image, completionBlock: completionBlock)
            case "GrayScale" :
                grayScaleFilter(imageRGBA: image, completionBlock: completionBlock)
            case "Red" :
                getRGBFilteredImage(red: 255, green: 0, blue: 0, image: image, completionBlock: completionBlock)
            case "Green" :
                getRGBFilteredImage(red: 0, green: 255, blue: 0, image: image, completionBlock: completionBlock)
            case "Blue" :
                getRGBFilteredImage(red: 0, green: 0, blue: 255, image: image, completionBlock: completionBlock)
            default:
                completionBlock(nil)
        }
    }
    
}
