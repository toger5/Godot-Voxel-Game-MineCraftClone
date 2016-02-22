#Copyright (c) 2015 OvermindDL1
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#
#OvermindDL1 would love to receive updates, fixes, and more to this code,
#though it is not required:  https://github.com/OvermindDL1/Godot-Helpers




const F2 = 0.36602540378443860
const G2 = 0.21132486540518714
const G2o = -0.577350269189626
const F3 = 0.33333333333333333
const G3 = 0.16666666666666666

const GRAD3 = [
	1,1,0,  -1,1,0,  1,-1,0, -1,-1,0, 
	1,0,1,  -1,0,1,  1,0,-1, -1,0,-1, 
	0,1,1,  0,-1,1,  0,1,-1, 0,-1,-1,
	1,0,-1, -1,0,-1, 0,-1,1, 0,1,1,
	]

const GRAD4 = [
	0,1,1,1,  0,1,1,-1,  0,1,-1,1,  0,1,-1,-1,
	0,-1,1,1, 0,-1,1,-1, 0,-1,-1,1, 0,-1,-1,-1,
	1,0,1,1,  1,0,1,-1,  1,0,-1,1,  1,0,-1,-1,
	-1,0,1,1, -1,0,1,-1, -1,0,-1,1, -1,0,-1,-1,
	1,1,0,1,  1,1,0,-1,  1,-1,0,1,  1,-1,0,-1,
	-1,1,0,1, -1,1,0,-1, -1,-1,0,1, -1,-1,0,-1,
	1,1,1,0,  1,1,-1,0,  1,-1,1,0,  1,-1,-1,0,
	-1,1,1,0, -1,1,-1,0, -1,-1,1,0, -1,-1,-1,0,
	]

const PERM = [
	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140,
	36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120,
	234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
	88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71,
	134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133,
	230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161,
	1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130,
	116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250,
	124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227,
	47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44,
	154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98,
	108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34,
	242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14,
	239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121,
	50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243,
	141, 128, 195, 78, 66, 215, 61, 156, 180, 151, 160, 137, 91, 90, 15, 131,
	13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37,
	240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252,
	219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125,
	136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158,
	231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245,
	40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187,
	208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198,
	173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126,
	255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223,
	183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167,
	43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185,
	112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179,
	162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199,
	106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236,
	05, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156,
	180,
	]


static func simplex2(c0, c1):
	var s = (c0+c1) * 0.36602540378443860
	var a0 = floor(c0+s)
	var a1 = floor(c1+s)
	var t = (a0+a1) * 0.21132486540518714
	
	var n0 = 0.0
	var n1 = 0.0
	var n2 = 0.0
	
	var p00 = c0-(a0-t)
	var p01 = 0.0
	var p02 = 0.0
	var p10 = c1-(a1-t)
	var p11 = 0.0
	var p12 = 0.0
	
	# Current gdscript casts false to 0 and true to 1
	var b0 = int(p00 > p10)
	var b1 = int(p00 <= p10)
	
	p01 = p00 - b0 + 0.21132486540518714
	p11 = p10 - b1 + 0.21132486540518714
	p02 = p00 + -0.577350269189626
	p12 = p10 + -0.577350269189626
	
	var A0 = int(a0)&255
	var A1 = int(a1)&255
	var g0 = (PERM[A0 + PERM[A1]] % 12) * 3
	var g1 = (PERM[A0 + b0 + PERM[A1 + b1]] % 12) * 3
	var g2 = (PERM[A0 + 1 + PERM[A1 + 1]] % 12) * 3
	
	var f0 = 0.5 - p00*p00 - p10*p10
	var f1 = 0.5 - p01*p01 - p11*p11
	var f2 = 0.5 - p02*p02 - p12*p12
	
	if f0 > 0:
		n0 = f0*f0*f0*f0 * (GRAD3[g0]*p00 + GRAD3[g0]*p10)
	if f1 > 0:
		n1 = f1*f1*f1*f1 * (GRAD3[g1 + 1]*p01 + GRAD3[g1 + 1]*p11)
	if f2 > 0:
		n2 = f2*f2*f2*f2 * (GRAD3[g2 + 2]*p02 + GRAD3[g2 + 2]*p12)
	
	return (n0 + n1 + n2) * 70.0